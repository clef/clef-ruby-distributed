require 'active_support'
require 'active_support/core_ext'

require 'clef/errors'
require 'clef/configuration'
require 'clef/requests'
require 'clef/signing'
require 'clef/client'

module Clef
  extend self

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
  delegate(*Signing.public_instance_methods(false), to: :client)
  delegate(*Client.public_instance_methods(false) - [:config], to: :client)
end