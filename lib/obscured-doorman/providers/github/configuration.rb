require File.expand_path('../../base/configuration', __FILE__)


module Obscured
  module Doorman
    module Providers
      module GitHub
        class Configuration < Obscured::Doorman::Providers::BaseConfiguration
          def initialize
            @config_values = {}

            # set default attribute values
            @defaults = OpenStruct.new(
              provider: Obscured::Doorman::Providers::GitHub,
              enabled: false,
              client_id: nil,
              client_secret: nil,
              scopes: 'user:email',
              authorize_url: 'https://github.com/login/oauth/authorize',
              token_url: 'https://github.com/login/oauth/access_token',
              login_url: '/doorman/oauth2/github',
              redirect_url: '/doorman/oauth2/github/callback',
              domains: [],
              token: nil
            )
          end
        end
      end
    end
  end
end