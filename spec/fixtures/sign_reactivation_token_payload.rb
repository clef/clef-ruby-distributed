require 'spec_helper'

RSpec.describe Clef, '#sign_reactivation_handshake_payload' do
  before do
    Clef.configure do |config|
      config.id = 'ID'
      config.secret = 'SECRET'
      config.keypair = config.keypair = File.read(File.join(File.dirname(__FILE__), 'fixtures', 'test.key'))
    end
  end
end