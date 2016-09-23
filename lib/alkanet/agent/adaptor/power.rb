require 'English'

module Alkanet
  module Agent
    module Adaptor
      module Power
        class << self
          def run(addr:, type: 'poweroff')
            system("sudo alk-power #{addr} #{type}")
            raise FailedPowerError, 'faild to execute alk-power' unless $CHILD_STATUS.success?
          end
        end
      end
    end
  end
end
