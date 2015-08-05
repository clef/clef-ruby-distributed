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

    def sign_login_payload(payload={})
      payload[:type] = "login"
      assert_keys_in_payload!(payload, [:clef_id, :nonce, :redirect_url, :session_id, :type])
      sign_payload(payload)
    end

    def sign_reactivation_handshake_payload(payload)
      payload[:type] = "reactivation_handshake"
      assert_keys_in_payload!(payload, [:type])
      sign_payload(payload)
    end

    def verify_login_payload!(payload, user_public_key)
      unless user_public_key.is_a?(RSA)
        user_public_key = RSA.new(user_public_key)
      end

      assert_payload_hash_valid!(payload)

      assert_signatures_present!(payload, [:application, :user])
      assert_signature_valid!(payload, :application, @config.keypair)
      assert_signature_valid!(payload, :user, user_public_key)

      true
    end

    def get_reactivation_payload(token)
      reactivation_handshake_payload = { reactivation_token: token }
      signed_reactivation_hanshake_payload = sign_reactivation_handshake_payload(reactivation_handshake_payload)
      encoded_reactivation_handshake_payload = Clef.encode_payload(signed_reactivation_hanshake_payload)

      response =  get("reactivations/#{token}/", {}, {"Authorization" => "Payload #{encoded_reactivation_handshake_payload}"} )
      reactivation_payload = symoblize_keys(response.body)

      verify_reactivation_payload!(reactivation_payload)

      JSON.parse reactivation_payload[:payload_json], symbolize_names: true
    end

    def encode_payload(payload)
      Base64.urlsafe_encode64(payload.to_json)
    end

    def decode_payload(payload)
      JSON.parse Base64.urlsafe_decode64(payload), symbolize_names: true
    end

    protected

    def symoblize_keys(hash)
      hash.inject({}) do |memo, (k, v)|
        memo[k.to_sym] = v.is_a?(Hash) ? symoblize_keys(v) : v
        memo
      end
    end
  end
end