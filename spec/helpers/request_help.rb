# frozen_string_literal: true

module Obscured::Doorman::Spec
  module Helpers
    FAILURE_APP = ->(_e) { [401, { 'Content-Type' => 'text/plain' }, ['You Fail!']] }

    def env_with_params(path = '/', params = {}, env = {})
      method = params.delete(:method) || 'GET'
      env = { 'HTTP_VERSION' => '1.1', 'REQUEST_METHOD' => method.to_s }.merge(env)
      Rack::MockRequest.env_for("#{path}?#{Rack::Utils.build_query(params)}", env)
    end

    def setup_rack(app = nil, opts = {}, &block)
      app ||= block if block_given?

      opts[:failure_app]         ||= failure_app
      opts[:default_strategies]  ||= [:password]
      opts[:default_serializers] ||= [:session]
      blk = opts[:configurator] || proc{}

      Rack::Builder.new do
        use opts[:session] || Helpers::Session unless opts[:nil_session]
        use Warden::Manager, opts, &blk
        run app
      end
    end

    def valid_response
      Rack::Response.new('OK').finish
    end

    def failure_app
      Helpers::FAILURE_APP
    end

    def success_app
      #lambda ..
      ->(e) { [200, {'Content-Type' => 'text/plain'}, ['You Win']] }
    end

    class Session
      attr_accessor :app
      def initialize(app, configs = {})
        @app = app
      end

      def call(e)
        e['rack.session'] ||= {}
        @app.call(e)
      end
    end
  end
end