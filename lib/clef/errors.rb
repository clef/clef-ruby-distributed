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

		class APIError < ClefError
			attr_reader :message
			attr_reader :type
			attr_reader :response

			def initialize(message, type=nil, response=nil)
				@message = message
				@type = type
				@response = response
			end

			def to_s
				"(#{type}) #{message}"
			end
		end
  end
end