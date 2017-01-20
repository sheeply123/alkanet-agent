require 'English'

module Alkanet
  module Agent
    module Adaptor
      module Logcat
        class << self
          def run(file, addr:, time: 30)
            start_flag = false

            IO.popen("sudo RBENV_VERSION=1.9.3-p484 alk-logcat #{addr} -o #{file.path} -t #{time}") do |pipe|
              pipe.each do |line|
                next unless !start_flag && line.start_with?('CAPTURE START')
                # success to start logcat
                yield
                start_flag = true
              end
            end

            raise FailedLogcatError, 'faild to execute alk-logcat' unless $CHILD_STATUS.success?

            # 途中でフリーズしていないか確認
            `sudo RBENV_VERSION=1.9.3-p484 alk-logcat #{addr} -t 0 -q`
            raise FailedLogcatError, 'faild to execute alk-logcat' unless $CHILD_STATUS.success?
          end
        end
      end
    end
  end
end
