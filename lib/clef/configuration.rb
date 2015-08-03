module Clef
  class Configuration
    attr_accessor :id
    attr_accessor :secret
    attr_accessor :passphrase
    attr_accessor :api_base

    def keypair
      return @keypair if @keypair

      unless @raw_keypair.present?
        raise Errors::Misconfiguration
      end

      @keypair = OpenSSL::PKey::RSA.new @raw_keypair, @passphrase
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