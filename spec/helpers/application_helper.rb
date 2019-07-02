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
      end
    end
  end
end