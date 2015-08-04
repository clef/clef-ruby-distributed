require 'spec_helper'

RSpec.describe Clef, '#get_reactivation_data' do
  it 'should call get with the correct url' do
    token = "123456"
    fake_payload = { test: true }

    allow(Clef.client).to receive(:sign_reactivation_handshake_payload).and_return(fake_payload)

    stub_request(:get, "https://clef.io/api/v1/reactivations/#{token}/")
      .with(headers: {"Authorization" => "Payload #{Clef.encode_payload(fake_payload)}"})
      .to_return(:status => 200, :body => "", :headers => {})

    Clef.get_reactivation_data(token)
  end
end