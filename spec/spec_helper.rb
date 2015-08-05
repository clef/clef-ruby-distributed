require 'bundler/setup'
Bundler.setup

require 'rspec'
require 'webmock/rspec'
require 'vcr'

require 'clef'

RSpec.configure do |config|
  config.before(:suite) do
    Clef.configure do |config|
      config.id = "ID"
      config.secret = "SECRET"
      config.keypair = OpenSSL::PKey::RSA.new(2048)
    end
  end

  config.order = 'random'
end

require 'support/vcr'