module Clef
  class Configuration
    attr_accessor :id
    attr_accessor :secret
    attr_accessor :passphrase
    attr_accessor :api_base
    attr_accessor :api_version
    attr_accessor :debug
    attr_accessor :logger

    attr_accessor :http_open_timeout
    attr_accessor :http_read_timeout


    def initialize
      @api_base = 'https://clef.io'
      @api_version = 'v1'
      @http_open_timeout = 2
      @http_read_timeout = 5
    end

    def keypair
      return @keypair if @keypair

      unless @raw_keypair.present?
        raise Errors::Misconfiguration
      end

      @keypair = OpenSSL::PKey::RSA.new @raw_keypair, @passphrase
    end

    def debug?
      @debug
    end

    def keypair=(value)
      if value.is_a?(OpenSSL::PKey::RSA)
        @keypair = value
      else
        @keypair = nil
        @raw_keypair = value
      end
    end
  end
end