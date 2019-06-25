# frozen_string_literal: true

require File.expand_path('../github/configuration', __FILE__)
require File.expand_path('../github/messages', __FILE__)
require File.expand_path('../github/access_token', __FILE__)
require File.expand_path('../github/strategy', __FILE__)


module Obscured
  module Doorman
    module Providers
      module GitHub
        class << self
          # Configuration Object (instance of Obscured::Doorman::Providers::GitHub::Configuration)
          attr_writer :configuration

          def setup
            yield(configuration)
          end

          def configuration
            @configuration ||= GitHub::Configuration.new
          end

          def default_configuration
            configuration.defaults
          end
        end


        def self.registered(app)
          app.helpers Obscured::Doorman::Base::Helpers
          app.helpers Obscured::Doorman::Helpers

          Warden::Strategies.add(:github, GitHub::Strategy)

          app.get '/doorman/oauth2/github' do
            redirect "#{GitHub.configuration[:authorize_url]}?client_id=#{GitHub.configuration[:client_id]}&response_type=code&scope=#{GitHub.configuration[:scopes]}"
          end

          app.get '/doorman/oauth2/github/callback/?' do
            response = RestClient::Request.new(
              method: :post,
              url: GitHub.configuration[:token_url],
              user: GitHub.configuration[:client_id],
              password: GitHub.configuration[:client_secret],
              payload: "code=#{params[:code]}&grant_type=authorization_code&scope=#{GitHub.configuration[:scopes]}",
              headers: { Accept: 'application/json' }
            ).execute

            json = JSON.parse(response.body)
            token = GitHub::AccessToken.new(
              access_token: json['access_token'],
              token_type: json['token_type'],
              scope: json['scope']
            )

            emails = RestClient.get 'https://api.github.com/user/emails',Authorization: "token #{token.access_token}"
            emails = JSON.parse(emails.body)
            token.emails = emails.map { |e| e['email'] }
            GitHub.configuration[:token] = token

            # Authenticate with :github strategy
            warden.authenticate!(:github)
          rescue RestClient::ExceptionWithResponse => e
            message = JSON.parse(e.response)
            Doorman.logger.error e
            notify :error, "#{message['error_description']} (#{message['error']})"
            redirect '/doorman/login'
          ensure
            # Notify if there are any messages from Warden.
            unless warden.message.blank?
              notify :error, warden.message
            end
            redirect Obscured::Doorman.configuration.use_referrer && session[:return_to] ? session.delete(:return_to) : Obscured::Doorman.configuration.paths[:success]
          end
        end
      end
    end
  end
end