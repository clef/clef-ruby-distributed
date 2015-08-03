module Clef
  module Errors
    class ClefError < StandardError
    end

    class Misconfiguration < ClefError
    end

    class InvalidPayloadError < ClefError
    end

    class VerificationError < ClefError
    end
  end
end