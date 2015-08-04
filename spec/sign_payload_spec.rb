require 'spec_helper'

RSpec.describe Clef, '#sign_payload' do

  SHA256 = OpenSSL::Digest::SHA256

  before do
    Clef.configure do |config|
      config.id = 'ID'
      config.secret = 'SECRET'
      config.keypair = config.keypair = File.read(File.join(File.dirname(__FILE__), 'fixtures', 'test.key'))
    end
  end

  it 'should encode the payload to json' do
    allow(Clef.client).to receive(:assert_keys_in_payload!).and_return(true)
    allow(Clef.client).to receive(:add_keys_to_payload!).and_return(true)

    payload_to_sign = { a: 1 }
    payload = Clef.sign_payload(payload_to_sign)

    expect(payload[:payload_json]).to eq(payload_to_sign.to_json)
  end

  it 'should sign the payload' do
    allow(Clef.client).to receive(:assert_keys_in_payload!).and_return(true)
    allow(Clef.client).to receive(:add_keys_to_payload!).and_return(true)

    payload_to_sign = { a: 1 }
    payload = Clef.sign_payload(payload_to_sign)

    decoded_signature = Base64.strict_decode64(payload[:signatures][:application][:signature])
    expect(decoded_signature).to eq(Clef.config.keypair.sign(SHA256.new, payload_to_sign.to_json))
  end

  it 'should hash the payload' do
    allow(Clef.client).to receive(:assert_keys_in_payload!).and_return(true)
    allow(Clef.client).to receive(:add_keys_to_payload!).and_return(true)

    payload_to_sign = { a: 1 }
    payload = Clef.sign_payload(payload_to_sign)

    expect(payload[:payload_hash]).to eq(SHA256.new.update(payload_to_sign.to_json).hexdigest)
  end

  it 'should create a signature that is verifiable by the public key' do
    allow(Clef.client).to receive(:assert_keys_in_payload!).and_return(true)
    allow(Clef.client).to receive(:add_keys_to_payload!).and_return(true)

    payload_to_sign = { a: 1 }
    payload = Clef.sign_payload(payload_to_sign)

    decoded_signature = Base64.strict_decode64(payload[:signatures][:application][:signature])
    expect(Clef.config.keypair.public_key.verify(SHA256.new, decoded_signature, payload_to_sign.to_json)).to be true
  end

  it 'should base64 encode the generated signature' do
    allow(Clef.client).to receive(:assert_keys_in_payload!).and_return(true)
    allow(Clef.config.keypair).to receive(:sign).and_return("signed")

    payload = Clef.sign_payload({ a: 1 })

    expect(payload[:signatures][:application][:signature]).to eq(Base64.strict_encode64("signed"))
  end

  it 'should sort the payload' do
    allow(Clef.client).to receive(:assert_keys_in_payload!).and_return(true)
    allow(Clef.client).to receive(:add_keys_to_payload!).and_return(true)

    unsorted_payload = { a: 1, c: 2, b: 3 }
    payload = Clef.sign_payload(unsorted_payload)

    sorted_payload = JSON.parse payload[:payload_json], symbolize_names: true
    expect(sorted_payload.keys).to eq([:a, :b, :c])
  end

  context 'it should add data to the payload' do
    it '[id]' do
      allow(Clef.client).to receive(:assert_keys_in_payload!).and_return(true)

      unsorted_payload = { a: 1, c: 2, b: 3 }
      payload = Clef.sign_payload(unsorted_payload)

      payload_json = JSON.parse payload[:payload_json], symbolize_names: true
      expect(payload_json[:application_id]).to eq(Clef.config.id)
    end

    it '[timestamp]' do
      allow(Clef.client).to receive(:assert_keys_in_payload!).and_return(true)
      allow(Time).to receive(:now).and_return(100)

      unsorted_payload = { a: 1, c: 2, b: 3 }
      payload = Clef.sign_payload(unsorted_payload)

      payload_json = JSON.parse payload[:payload_json], symbolize_names: true
      expect(payload_json[:timestamp]).to eq(100 * 1000)
    end
  end

  context 'it should assert keys in the payload' do
    it '[clef_id]' do
      expect {
        payload = Clef.sign_payload({})
      }.to raise_error(Clef::Errors::InvalidPayloadError, "Missing clef_id in payload.")
    end

    it '[nonce]' do
      expect {
        payload = Clef.sign_payload({ clef_id: '1234' })
      }.to raise_error(Clef::Errors::InvalidPayloadError, "Missing nonce in payload.")
    end

    it '[redirect_url]' do
      expect {
        payload = Clef.sign_payload({ clef_id: '1234', nonce: '1234' })
      }.to raise_error(Clef::Errors::InvalidPayloadError, "Missing redirect_url in payload.")
    end

    it '[session_id]' do
      expect {
        payload = Clef.sign_payload({ clef_id: '1234', nonce: '1234', redirect_url: '1234' })
      }.to raise_error(Clef::Errors::InvalidPayloadError, "Missing session_id in payload.")
    end

    it '[type]' do
      expect {
        payload = Clef.sign_payload({ clef_id: '1234', nonce: '1234', redirect_url: '1234', session_id: '1234' })
      }.to raise_error(Clef::Errors::InvalidPayloadError, "Missing type in payload.")
    end
  end

end