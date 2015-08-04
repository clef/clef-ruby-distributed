require 'spec_helper'

RSpec.describe Clef, '#sign_login_payload' do
  context 'it should assert keys in the payload' do
    it '[clef_id]' do
      expect {
        payload = Clef.sign_login_payload({})
      }.to raise_error(Clef::Errors::InvalidPayloadError, "Missing clef_id in payload.")
    end

    it '[nonce]' do
      expect {
        payload = Clef.sign_login_payload({ clef_id: '1234' })
      }.to raise_error(Clef::Errors::InvalidPayloadError, "Missing nonce in payload.")
    end

    it '[redirect_url]' do
      expect {
        payload = Clef.sign_login_payload({ clef_id: '1234', nonce: '1234' })
      }.to raise_error(Clef::Errors::InvalidPayloadError, "Missing redirect_url in payload.")
    end

    it '[session_id]' do
      expect {
        payload = Clef.sign_login_payload({ clef_id: '1234', nonce: '1234', redirect_url: '1234' })
      }.to raise_error(Clef::Errors::InvalidPayloadError, "Missing session_id in payload.")
    end
  end

end