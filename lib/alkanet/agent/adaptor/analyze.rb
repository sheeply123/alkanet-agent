module Alkanet
  module Agent
    module Adaptor
      module Analyze
        class << self
          def run(report, logfile, exe_name)
            report.write `sudo alk-analyze2 #{logfile.path} #{exe_name}`

            status = $?
            raise FailedAnalyzeError, 'faild to execute alk-analyze2' unless status.success?
          end
        end
      end
    end
  end
end
