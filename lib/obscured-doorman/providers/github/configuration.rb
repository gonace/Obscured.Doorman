# frozen_string_literal: true

require File.expand_path('../base/configuration', __dir__)

module Obscured
  module Doorman
    module Providers
      module GitHub
        class Configuration < Doorman::Providers::BaseConfiguration
          def initialize
            @config_values = {}

            # set default attribute values
            @defaults = _defaults
          end

          private

          def _defaults
            OpenStruct.new(
              provider: Doorman::Providers::GitHub,
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
