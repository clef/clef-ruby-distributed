require 'base64'
require 'json'

module Clef
  class Client
    include Clef::Signing
    include Clef::Requests

    attr_accessor :config

    def initialize(config=Clef.config.dup, options={})
      @config = config
    end

    def get_reactivation_data(token)
      payload = { reactivation_token: token }
      signed_payload = sign_reactivation_handshake_payload(payload)

      get(
        "reactivations/#{token}/",
        {},
        {"Authorization" => "Payload #{Clef.encode_payload(signed_payload)}"}
      ).body
    end

    def encode_payload(payload)
      Base64.urlsafe_encode64(payload.to_json)
    end

    def decode_payload(payload)
      JSON.parse Base64.urlsafe_decode64(payload), symbolize_names: true
    end
  end
end