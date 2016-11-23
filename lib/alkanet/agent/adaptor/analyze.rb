require 'English'

module Alkanet
  module Agent
    module Adaptor
      module Analyze
        class << self
          def run(report, logfile, exe_name)
            report.write `RBENV_VERSION=1.9.3-p484 alk-analyze2 #{logfile.path} #{exe_name}`
            raise FailedAnalyzeError, 'faild to execute alk-analyze2' unless $CHILD_STATUS.success?
          end
        end
      end
    end
  end
end
