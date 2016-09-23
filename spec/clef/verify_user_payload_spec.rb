require 'spec_helper'
require 'base64'

RSpec.describe Clef, '#verify_login_payload!' do

  SHA = OpenSSL::Digest::SHA256

  before do
    @user_key = OpenSSL::PKey::RSA.new()
  end

  it 'should validate on a valid payload' do
    allow(Clef.config.keypair).to receive(:verify).and_return(true)
    allow(@user_key).to receive(:verify).and_return(true)

    payload_json = { a: 1 }.to_json
    payload_hash = SHA.new.update(payload_json).hexdigest

    payload = {
      payload_json: payload_json,
      payload_hash: payload_hash,
      signatures: {
        application: {
          signature: Base64.strict_encode64('goodsignature')
        },
        user: {
          signature: Base64.strict_encode64('goodsignature')
        }
      }
    }

    expect(Clef.verify_login_payload!(payload, @user_key)).to be(true)
  end
  it 'should raise an exception if the hash is invalid' do
    allow(Clef.client).to receive(:assert_signatures_present!).and_return(true)

    payload_json = { a: 1 }.to_json
    payload_hash = "badhash"

    expect {
      Clef.verify_login_payload!(
        {
          payload_json: payload_json,
          payload_hash: payload_hash
        },
        @user_key
      )
    }.to raise_error(Clef::Errors::VerificationError, "Invalid payload hash.")
  end

  it 'should raise an exception if the application signature is invalid' do
    allow(Clef.client).to receive(:assert_signatures_present!).and_return(true)

    payload_json = { a: 1 }.to_json
    payload_hash = SHA.new.update(payload_json).hexdigest

    expect {
      Clef.verify_login_payload!(
        {
          payload_json: payload_json,
          payload_hash: payload_hash,
          signatures: {
            application: {
              signature: 'badsignature'
            }
          }
        },
        @user_key
      )
    }.to raise_error(Clef::Errors::VerificationError, "Invalid application signature.")
  end

  it 'should raise an exception if the application signature is invalid' do
    allow(Clef.client).to receive(:assert_signatures_present!).and_return(true)
    allow(Clef.config.keypair).to receive(:verify).and_return(true)
    allow(@user_key).to receive(:verify).and_return(false)

    payload_json = { a: 1 }.to_json
    payload_hash = SHA.new.update(payload_json).hexdigest

    expect {
      Clef.verify_login_payload!(
        {
          payload_json: payload_json,
          payload_hash: payload_hash,
          signatures: {
            application: {
              signature: 'badsignature'
            },
            user: {
              signature: 'badsignature'
            }
          }
        },
        @user_key
      )
    }.to raise_error(Clef::Errors::VerificationError, "Invalid user signature.")
  end

  context 'should validate signatures are present' do
    it '[signatures]' do
      payload_json = { a: 1 }.to_json
      payload_hash = SHA.new.update(payload_json).hexdigest

      expect {
        Clef.verify_login_payload!(
          {
            payload_json: payload_json,
            payload_hash: payload_hash
          },
          @user_key
        )
      }.to raise_error(Clef::Errors::VerificationError, "No signatures provided")
    end

    it '[application]' do
      payload_json = { a: 1 }.to_json
      payload_hash = SHA.new.update(payload_json).hexdigest

      expect {
        Clef.verify_login_payload!(
          {
            payload_json: payload_json,
            payload_hash: payload_hash,
            signatures: {
              user: {}
            }
          },
          @user_key
        )

      }.to raise_error(Clef::Errors::VerificationError, "No application signature provided")

      expect {
        Clef.verify_login_payload!(
          {
            payload_json: payload_json,
            payload_hash: payload_hash,
            signatures: {
              application: {

              }
            }
          },
          @user_key
        )

      }.to raise_error(Clef::Errors::VerificationError, "No application signature provided")

    end

    it '[user]' do
      payload_json = { a: 1 }.to_json
      payload_hash = SHA.new.update(payload_json).hexdigest

      expect {
        Clef.verify_login_payload!(
          {
            payload_json: payload_json,
            payload_hash: payload_hash,
            signatures: {
              application: {
                signature: "goodsignature"
              }
            }
          },
          @user_key
        )

      }.to raise_error(Clef::Errors::VerificationError, "No user signature provided")

      expect {
        Clef.verify_login_payload!(
          {
            payload_json: payload_json,
            payload_hash: payload_hash,
            signatures: {
              application: {
                signature: "goodsignature"
              },
              user: {

              }
            }
          },
          @user_key
        )

      }.to raise_error(Clef::Errors::VerificationError, "No user signature provided")

    end
  end

end
