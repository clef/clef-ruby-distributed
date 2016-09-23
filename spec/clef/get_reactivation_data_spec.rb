require 'spec_helper'

RSpec.describe Clef, '#get_reactivation_data' do
  it 'should call get with the correct url' do
    token = "123456"

    VCR.use_cassette("reactivations") do
      allow(Clef.client).to receive(:verify_reactivation_payload!).and_return(true)
      payload = Clef.get_reactivation_payload(token)
    end
  end

  it "should raise an exception with an error" do
    token = "badtoken"

    VCR.use_cassette("reactivations") do
      expect {
        payload = Clef.get_reactivation_payload(token)
      }.to raise_error(Clef::Errors::APIError)
    end
  end
end
