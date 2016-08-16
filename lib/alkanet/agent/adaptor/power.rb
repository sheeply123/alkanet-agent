module Alkanet
  module Agent
    module Adaptor
      module Power
        class << self
          def run(type)
            system('sudo alk-power #{type}')
            $?.tap{ |status|
              raise FailedPowerError, 'faild to execute alk-power' unless status.success?
            }
          end
        end
      end
    end
  end
end
