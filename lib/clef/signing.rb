require 'base64'
require 'json'

module Clef
  SHA256 = OpenSSL::Digest::SHA256
  RSA = OpenSSL::PKey::RSA

  module Signing
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

    def verify_reactivation_payload!(payload, options={})
      assert_payload_hash_valid!(payload)
      assert_signatures_present!(payload, [:initiation])
      assert_signature_valid!(payload, :initiation, @config.initiation_public_key)

      if options[:unsafe_do_not_verify_confirmation_signature]
        assert_test_payload!(payload)
      else
        assert_signatures_present!(payload, [:confirmation])
        assert_signature_valid!(payload, :confirmation, @config.confirmation_public_key)
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

    def assert_test_payload!(payload)
      raise Errors::InvalidPayloadError, "Missing test in payload." if not payload.key?(:test)
      raise Errors::VerificationError, "Invalid test payload" if not payload[:test]
    end

    def assert_signatures_present!(payload, signature_types)
      unless payload[:signatures].present?
        raise Errors::VerificationError, "No signatures provided"
      end

      signature_types.map do |type|
        is_present = payload[:signatures][type].present? and payload[:signatures][type][:signature].present?

        unless is_present
          raise Errors::VerificationError, "No #{type} signature provided"
        end
      end
    end

    def assert_payload_hash_valid!(payload)
      payload_hash = SHA256.new.update(payload[:payload_json]).hexdigest
      hash_is_valid = (payload_hash.present? and payload[:payload_hash].present? and payload_hash == payload[:payload_hash])

      unless hash_is_valid
        raise Errors::VerificationError, "Invalid payload hash."
      end
    end

    def assert_signature_valid!(payload, signature_type, public_key)
      signature_is_valid = public_key.verify(
        SHA256.new,
        Base64.strict_decode64(payload[:signatures][signature_type][:signature]),
        payload[:payload_json]
      )

      unless signature_is_valid
        raise Errors::VerificationError, "Invalid #{signature_type} signature."
      end
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