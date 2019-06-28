# frozen_string_literal: true

require File.expand_path('../base/configuration', __dir__)

module Obscured
  module Doorman
    module Providers
      module Bitbucket
        class Configuration < Doorman::Providers::BaseConfiguration
          def initialize
            @config_values = {}

            # set default attribute values
            @defaults = _defaults
          end

          private

          def _defaults
            OpenStruct.new(
              provider: Doorman::Providers::Bitbucket,
              enabled: false,
              client_id: nil,
              client_secret: nil,
              scopes: 'account',
              authorize_url: 'https://bitbucket.org/site/oauth2/authorize',
              token_url: 'https://bitbucket.org/site/oauth2/access_token',
              login_url: '/doorman/oauth2/bitbucket',
              redirect_url: '/doorman/oauth2/bitbucket/callback',
              domains: [],
              token: nil
            )
          end
        end
      end
    end
  end
end
