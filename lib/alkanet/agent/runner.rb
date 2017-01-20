require 'tempfile'

module Alkanet
  module Agent
    module Runner
      class << self
        def run(opt)
          self.option = opt
          power_flag = true
          puts 'find collector and tracers info'
          tracers = find_tracers

          # 現状は1台のみ対応
          tracer = tracers.find{|data| data[:status] != 'unused'}
          job = find_job(tracer)

          puts "target job id is #{job[:id]}"
          puts 'wait changing job status to downloaded'
          wait_changed_job_status(job, 'downloaded')

          puts 'execute alk-logcat'
          tracelog, logcat_error = logcat(job)

          puts 'poweroff tracer'
          api_clinet.update_job_info(job[:id], status: 'poweroff_tracer')
          power_flag = false

          puts 'upload tracelog'
          upload_tracelog(job, tracelog)

          if option['analyze']
            puts 'execute alk-analyze2 and upload report'
            analyze(job, tracelog)
          else
            puts 'skip analyze'
          end

          if logcat_error
            puts 'failed'
            api_clinet.update_job_info(job[:id], status: 'failed')
            exit(-1)
          else
            puts 'done'
            api_clinet.update_job_info(job[:id], status: 'done')
          end

        rescue OptionError, MissingInfoError => e
          STDERR.puts e.message
          exit(-1)
        rescue Faraday::Error::ClientError => e
          STDERR.puts e.message
          res = e.response
          if res && res[:body] && res[:body].is_a?(Hash)
            Array(res[:body][:errors]).each do |error|
              STDERR.puts error[:message]
            end
          end
          if power_flag
            puts 'poweroff tracer'
            api_clinet.update_job_info(job[:id], status: 'poweroff_tracer')
          end
          api_clinet.update_job_info(job[:id], status: 'failed')
          exit(-1)
        end

        private

        attr_reader :option

        def option=(opt)
          raise OptionError, 'URL option is required' unless opt['url']
          @option = opt
        end

        def api_clinet
          @api_clinet ||= Request.new url: option['url']
        end

        def find_tracers
          json = api_clinet.fetch_collector_info.body
          json[:computer][:tracers].tap do |tracers|
            raise MissingInfoError, 'connected tracer is not found' if tracers.empty?
          end
        end

        def find_job(tracer)
          tracer[:job].tap do |job|
            raise MissingInfoError, 'job is not assigned' unless job
          end
        end

        def wait_changed_job_status(job, status)
          loop do
            json = api_clinet.fetch_job_info(job[:id]).body
            return if json[:job][:status] == status
            sleep 3
          end
        end

        def logcat(job)
          error = nil
          tracelog = Tempfile.new("tracelog#{job[:id]}")
          begin
            Adaptor::Logcat.run(tracelog, addr: option['addr'], time: job[:seconds]) do
              api_clinet.update_job_info(job[:id], status: 'collecting')
            end
          rescue FailedLogcatError => e
            STDERR.puts e.message
            error = e
          end
          api_clinet.update_job_info(job[:id], status: 'collected')
          [tracelog, error]
        end

        def upload_tracelog(job, tracelog)
          api_clinet.update_job_info(job[:id], status: 'uploading_tracelog')
          api_clinet.upload_tracelog(job[:id], tracelog.path)
          api_clinet.update_job_info(job[:id], status: 'uploaded_tracelog')
        end

        def analyze(job, tracelog)
          api_clinet.update_job_info(job[:id], status: 'analyzing')
          report = Tempfile.new("report#{job[:id]}")
          Adaptor::Analyze.run(report, tracelog, job[:name])
          api_clinet.update_job_info(job[:id], status: 'analyzed')

          api_clinet.update_job_info(job[:id], status: 'uploading_report')
          api_clinet.upload_report(job[:id], report.path)
          api_clinet.update_job_info(job[:id], status: 'uploaded_report')
        rescue FailedAnalyzeError => e
          STDERR.puts e.message
        end
      end
    end
  end
end
