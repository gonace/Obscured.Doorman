# frozen_string_literal: true

module Obscured
  module Doorman
    module Spec
      class App < Sinatra::Base
        helpers Obscured::Doorman::Helpers
        register Sinatra::Flash

        use Rack::Session::Cookie,
            key: 'rack.session',
            path: '/',
            secret: 'rspec_secret'
        use Obscured::Doorman::Middleware

        Obscured::Doorman::Middleware.set :views, "#{File.dirname(__FILE__)}/../views/doorman"

        get '/home' do
          authorize!

          'Hello World!'
        end

        get '/session' do
          authenticate

          { session: session_info, user: user }.to_json
        end

        get '/user' do
          authorized?
          content_type :json

          { user: user }.to_json
        end

        get '/user/xml' do
          authorized?(:xml)
          content_type :xml

          { user: user }.to_xml
        end

        get '/logout' do
          authorized?

          logout
        end
      end
    end
  end
end
