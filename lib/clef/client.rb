require 'base64'
require 'json'

module Clef
  class Client
    attr_reader :config

    def initialize(config=Clef.config.dup, options={})
      @config = config
    end

    def signer
      @signer ||= Clef::Signer.new(@config)
    end

    def encode_payload(payload)
      Base64.urlsafe_encode64(payload.to_json)
    end

    def decode_payload(payload)
      JSON.parse Base64.urlsafe_decode64(payload), symbolize_names: true
    end

    delegate(*Clef::Signer.public_instance_methods(false), to: :signer)
  end
end