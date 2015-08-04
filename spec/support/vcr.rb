require 'vcr'
require 'webmock'

VCR.configure do |config|
  config.cassette_library_dir = File.expand_path('../../cassettes', __FILE__)
  config.hook_into :webmock
  config.ignore_localhost = true
end

WebMock.disable_net_connect!(:allow_localhost => true)