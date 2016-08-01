module Alkanet
  module Agent
    module LogcatAdaptor
      class << self
        def run(file, second = 30)
          start_flag = false

          IO.popen("sudo alk-logcat -o #{file.path} -t #{second}") do |pipe|
            pipe.each do |line|
              if !start_flag && line == 'CAPTURE START'
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
