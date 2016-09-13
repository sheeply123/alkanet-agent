module Alkanet
  module Agent
    module Adaptor
      module Power
        class << self
          def run(opt = {addr: nil, type: nil})
            system("sudo alk-power #{opt[:addr]} #{opt[:type]}")
            $?.tap{ |status|
              raise FailedPowerError, 'faild to execute alk-power' unless status.success?
            }
          end
        end
      end
    end
  end
end
