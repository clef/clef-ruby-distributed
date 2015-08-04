require 'faraday'
require 'faraday_middleware'
require 'json'
require 'active_support/concern'

module Clef
  module Requests
    extend ActiveSupport::Concern

    included do
      delegate :get, :post, :put, :delete, :patch, to: :connection
    end

    def connection
      @connection ||= Faraday.new api_endpoint, connection_options do |conn|
        conn.use Faraday::Response::RaiseError

        conn.request :json
        conn.response :json, content_type: /\bjson$/

        if config.debug?
          conn.response :logger, config.logger
        end

        conn.adapter Faraday.default_adapter
      end
    end

    private

    def api_endpoint
      "#{config.api_base}/api/#{config.api_version}/"
    end

    def connection_options
      {
        :headers => {
          :accept => 'application/json',
          :user_agent => user_agent
        },
        :request => {
          :open_timeout => config.http_open_timeout,
          :timeout => config.http_read_timeout
        },
        :ssl => {
          :verify_mode => OpenSSL::SSL::VERIFY_PEER
        }
      }
    end

    def user_agent
      'clef-ruby/%s (Rubygems; Ruby %s %s)' % [Clef::VERSION, RUBY_VERSION, RUBY_PLATFORM]
    end
  end
end