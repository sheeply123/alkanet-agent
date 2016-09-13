module Alkanet
  module Agent
    module Adaptor
      module Logcat
        class << self
          def run(file, opt = {addr: nil, time: 30})
            start_flag = false

            IO.popen("sudo alk-logcat #{opt[:addr]} -o #{file.path} -t #{opt[:time]} -q") do |pipe|
              pipe.each do |line|
                if !start_flag && line.start_with?('CAPTURE START')
                  # success to start logcat
                  yield
                  start_flag = true
                end
              end
            end

            status = $?
            raise FailedLogcatError, 'faild to execute alk-logcat' unless status.success?
          end
        end
      end
    end
  end
end
