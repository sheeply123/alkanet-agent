module Alkanet
  module Agent
    class MissingInfoError < StandardError
    end

    class FailedLogcatError < StandardError
    end

    class FailedAnalyzeError < StandardError
    end

    class FailedPowerError < StandardError
    end

    class OptionError < StandardError
    end
  end
end
