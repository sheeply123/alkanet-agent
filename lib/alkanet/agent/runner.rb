require 'tempfile'

module Alkanet
  module Agent
    module Runner
      class << self
        def run(opt)
          self.option = opt
          puts 'find collector and tracers info'
          tracers = find_tracers

          # 現状は1台のみ対応
          tracer = tracers.first
          job = find_job(tracer)

          puts "target job id is #{job[:id]}"
          puts 'wait canging job status to downloaded'
          wait_changed_job_status(job, 'downloaded')

          puts 'execute alk-logcat'
          tracelog = logcat(job)

          puts 'poweroff tracer'
          power('poweroff')
          api_clinet.update_job_info(job[:id], status: 'poweroff_tracer')

          puts 'upload tracelog'
          upload_tracelog(job, tracelog)

          if option['analyze']
            puts 'execute alk-analyze2 and upload report'
            analyze(job, tracelog)
          else
            puts 'skip analyze'
          end

          puts 'done'
          api_clinet.update_job_info(job[:id], status: 'done')

        rescue OptionError, MissingInfoError => e
          STDERR.puts e.message
          exit(-1)
        rescue FailedLogcatError => e
          STDERR.puts e
          api_clinet.update_job_info(job[:id], status: 'assigned')
          begin
            power('reset')
          rescue FailedPowerError => e
            STDERR.puts e
          end
          exit(-1)
        rescue FailedPowerError => e
          STDERR.puts e
          api_clinet.update_job_info(job[:id], status: 'assigned')
          exit(-1)
        rescue Faraday::Error::ClientError => e
          STDERR.puts e.message
          res = e.response
          if res && res[:body]
            Array(res[:body][:errors]).each do |error|
              STDERR.puts error[:message]
            end
          end
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
          tracelog = Tempfile.new("tracelog#{job[:id]}")
          Adaptor::Logcat.run(tracelog, addr: option['addr'], time: option['time']) do
            api_clinet.update_job_info(job[:id], status: 'collecting')
          end

          api_clinet.update_job_info(job[:id], status: 'collected')
          tracelog
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

        def power(type)
          Adaptor::Power.run(addr: option['addr'], type: type)
        end
      end
    end
  end
end
