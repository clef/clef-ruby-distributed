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

    attr_accessor :initiation_public_key
    attr_accessor :confirmation_public_key


    def initialize
      @api_base = 'https://clef.io'
      @api_version = 'v1'
      @http_open_timeout = 2
      @http_read_timeout = 5

      @initiation_public_key = OpenSSL::PKey::RSA.new File.read(File.join(File.dirname(__FILE__), '..', '..', 'resources', 'keys', 'initiation.pem'))
      @confirmation_public_key = OpenSSL::PKey::RSA.new File.read(File.join(File.dirname(__FILE__), '..', '..', 'resources', 'keys', 'confirmation.pem'))
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

    private
  end
end