# frozen_string_literal: true

module Obscured
  module Doorman
    module Strategies
      class Password < Warden::Strategies::Base
        def valid?
          params['user'] &&
            params['user']['username'] &&
            params['user']['password']
        end

        def authenticate!
          fail!(Doorman::MESSAGES[:login_bad_credentials]) unless valid?

          user = User.authenticate(
            params['user']['username'],
            params['user']['password']
          )

          if user.nil?
            fail!(Doorman::MESSAGES[:login_bad_credentials])
          elsif Doorman.configuration[:confirmation] && !user.confirmed
            token = user.confirm

            if File.exist?('views/doorman/templates/account_activation.haml')
              template = haml :'/templates/account_activation', layout: false, locals: {
                user: user.username,
                link: token_link('confirm', token.token)
              }
              Doorman::Mailer.new(
                to: user.username,
                subject: 'Account activation request',
                text: "You have to activate your account (#{user.username}) before using this service. " + token_link('confirm', token.token),
                html: template
              ).deliver!
            else
              Doorman.logger.warn "Template not found (views/doorman/templates/account_activation.haml), account activation at #{token_link('confirm', token.token)}"
            end

            fail!(Doorman::MESSAGES[:login_not_confirmed])
          else
            success!(user)
          end
        end

        private

        def token_link(action, token)
          "http://#{env['HTTP_HOST']}/doorman/#{action}/#{token}"
        end
      end
    end
  end
end
