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

          # TODO: shutdown

          if option['analyze']
            puts 'execute alk-analyze2'
            analyze(job, tracelog)
          else
            puts 'skip analyze'
          end

          api_clinet.update_job_info(job[:id], {status: 'done'})
        rescue OptionError, MissingInfoError => e
          STDERR.puts e.message
          exit(-1)
        rescue FailedLogcatError => e
          STDERR.puts e
          api_clinet.update_job_info(job[:id], {status: 'assigned'})
          # TODO: reboot
          exit(-1)
        rescue FailedAnalyzeError => e
          STDERR.puts e.message
          # TODO: rollback status
          exit(-1)
        rescue Faraday::Error::ClientError => e
          STDERR.puts e.message
          res = e.response
          if res
            json = res[:body]
            if json
              Array(json[:errors]).each do |error|
                STDERR.puts error[:message]
              end
            end
          end
          exit(-1)
        end

        private

        def option
          @option
        end

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
            if json[:job][:status] == status
              return
            end
            sleep 3
          end
        end

        def logcat(job)
          tracelog = Tempfile.new("tracelog#{job[:id]}")
          LogcatAdaptor.run(tracelog, 30) do
            api_clinet.update_job_info(job[:id], {status: 'collecting'})
          end

          api_clinet.upload_tracelog(job[:id], tracelog.path)
          api_clinet.update_job_info(job[:id], {status: 'collected'})
          tracelog
        end

        def analyze(job, logfile)
          api_clinet.update_job_info(job[:id], {status: 'analyzing'})
          report = Tempfile.new("report#{job[:id]}")
          AnalyzeAdaptor.run(report, logfile, job[:name])

          api_clinet.upload_report(job[:id], report.path)
          api_clinet.update_job_info(job[:id], {status: 'analyzed'})
          report
        end
      end
    end
  end
end
