require 'English'

module Alkanet
  module Agent
    module Adaptor
      module Logcat
        class << self
          def run(file, addr:, time: 30)
            start_flag = false

            IO.popen("sudo alk-logcat #{addr} -o #{file.path} -t #{time} -q") do |pipe|
              pipe.each do |line|
                next unless !start_flag && line.start_with?('CAPTURE START')
                # success to start logcat
                yield
                start_flag = true
              end
            end

            raise FailedLogcatError, 'faild to execute alk-logcat' unless $CHILD_STATUS.success?
          end
        end
      end
    end
  end
end
