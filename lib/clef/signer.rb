require 'base64'
require 'json'

module Clef
  SHA256 = OpenSSL::Digest::SHA256
  RSA = OpenSSL::PKey::RSA

  class Signer
    def initialize(config)
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

    def sign_payload(payload={})
      payload = symoblize_keys(payload)

      add_keys_to_payload!(payload)

      payload_json = sort_hash(payload).to_json
      payload_hash = SHA256.new.update(payload_json).hexdigest
      payload_signature = @config.keypair.sign(SHA256.new, payload_json)

      sort_hash({
        payload_json: payload_json,
        payload_hash: payload_hash,
        signatures: {
          application: {
            signature: Base64.strict_encode64(payload_signature),
            type: 'rsa-sha256'
          }
        }
      })
    end

    def verify_payload!(payload, user_public_key)
      unless user_public_key.is_a?(RSA)
        user_public_key = RSA.new(user_public_key)
      end

      assert_signatures_present!(payload)

      payload_hash = SHA256.new.update(payload[:payload_json]).hexdigest
      hash_is_valid = (payload_hash.present? and payload[:payload_hash].present? and payload_hash == payload[:payload_hash])

      unless hash_is_valid
        raise Errors::VerificationError, "Invalid payload hash."
      end

      application_signature_is_valid = @config.keypair.verify(
        SHA256.new,
        Base64.strict_decode64(payload[:signatures][:application][:signature]),
        payload[:payload_json]
      )

      unless application_signature_is_valid
        raise Errors::VerificationError, "Invalid application signature."
      end

      user_signature_is_valid = user_public_key.verify(
        SHA256.new,
        Base64.strict_decode64(payload[:signatures][:user][:signature]),
        payload[:payload_json]
      )

      unless user_signature_is_valid
        raise Errors::VerificationError, "Invalid user signature."
      end

      true
    end


    private

    def add_keys_to_payload!(payload)
      payload[:application_id] = @config.id
      payload[:timestamp] = (Time.now.to_f * 1000).to_i
    end

    def assert_keys_in_payload!(payload, keys)
      keys.map do |key|
        raise Errors::InvalidPayloadError, "Missing #{key} in payload." if payload[key].nil?
      end
    end

    def assert_signatures_present!(payload)
      unless payload[:signatures].present?
        raise Errors::VerificationError, "No signatures provided"
      end

      unless payload[:signatures][:application].present? and payload[:signatures][:application][:signature].present?
        raise Errors::VerificationError, "No application signature provided"
      end

      unless payload[:signatures][:user].present? and payload[:signatures][:user][:signature].present?
        raise Errors::VerificationError, "No user signature provided"
      end
    end

    def symoblize_keys(hash)
      hash.inject({}) { | memo, (k, v) | memo[k.to_sym] = v; memo}
    end

    def sort_hash(h)
      {}.tap do |h2|
        h.sort.each do |k,v|
          h2[k] = v.is_a?(Hash) ? sort_hash(v) : v
        end
      end
    end
  end
end