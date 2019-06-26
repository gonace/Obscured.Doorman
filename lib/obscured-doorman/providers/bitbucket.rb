# frozen_string_literal: true

require File.expand_path('bitbucket/configuration', __dir__)
require File.expand_path('bitbucket/messages', __dir__)
require File.expand_path('bitbucket/access_token', __dir__)
require File.expand_path('bitbucket/strategy', __dir__)


module Obscured
  module Doorman
    module Providers
      module Bitbucket
        class << self
          # Configuration Object (instance of Obscured::Doorman::Providers::Bitbucket::Configuration)
          attr_writer :configuration

          def setup
            yield(configuration)
          end

          def configuration
            @configuration ||= Bitbucket::Configuration.new
          end

          def default_configuration
            configuration.defaults
          end
        end


        def self.registered(app)
          app.helpers Doorman::Base::Helpers
          app.helpers Doorman::Helpers

          Warden::Strategies.add(:bitbucket, Bitbucket::Strategy)

          app.get '/doorman/oauth2/bitbucket' do
            redirect "#{Bitbucket.configuration[:authorize_url]}?client_id=#{Bitbucket.configuration[:client_id]}&response_type=code&scopes=#{Bitbucket.configuration[:scopes]}"
          end

          app.get '/doorman/oauth2/bitbucket/callback/?' do
            response = RestClient::Request.new(
              method: :post,
              url: Bitbucket.configuration[:token_url],
              user: Bitbucket.configuration[:client_id],
              password: Bitbucket.configuration[:client_secret],
              payload: "code=#{params[:code]}&grant_type=authorization_code&scope=#{Bitbucket.configuration[:scopes]}",
              headers: { Accept: 'application/json' }
            ).execute

            json = JSON.parse(response.body)
            token = Bitbucket::AccessToken.new(
              access_token: json['access_token'],
              refresh_token: json['refresh_token'],
              scopes: json['scopes'],
              expires_in: json['expires_in']
            )

            emails = RestClient.get 'https://api.bitbucket.org/2.0/user/emails', Authorization: "Bearer #{token.access_token}"
            emails = JSON.parse(emails.body)
            token.emails = emails.values[1].map { |e| e['email'] }
            Bitbucket.configuration[:token] = token

            # Authenticate with :bitbucket strategy
            warden.authenticate!(:bitbucket)
          rescue RestClient::ExceptionWithResponse => e
            message = JSON.parse(e.response)
            Doorman.logger.error e
            notify :error, "#{message['error_description']} (#{message['error']})"
            redirect(Doorman.configuration.paths[:login])
          ensure
            # Notify if there are any messages from Warden.
            notify :error, warden.message unless warden.message.blank?

            redirect(Doorman.configuration.use_referrer && session[:return_to] ? session.delete(:return_to) : Doorman.configuration.paths[:success])
          end
        end
      end
    end
  end
end