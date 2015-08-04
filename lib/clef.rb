require 'active_support'
require 'active_support/core_ext'

require 'clef/errors'
require 'clef/configuration'
require 'clef/client'

module Clef
  extend self

  API_BASE = 'https://clef.io'.freeze

  def configure
    yield(config)
  end

  def config
    @config ||= Configuration.new
  end

  def new(config=Clef.config.dup, options={})
    Client.new(config, options)
  end

  def client
    @client ||= new(config)
  end

  delegate(*Configuration.public_instance_methods(false), to: :config)
  delegate(*Client.public_instance_methods(false) - [:config], to: :client)
end