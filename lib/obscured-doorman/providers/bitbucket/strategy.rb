# frozen_string_literal: true

require 'haml'
require File.expand_path('messages', __dir__)

module Obscured
  module Doorman
    module Providers
      module Bitbucket
        class Strategy < Warden::Strategies::Base
          def valid?
            emails = Bitbucket.configuration[:token].emails

            if Bitbucket.configuration[:domains].nil?
              return true if emails.length.positive?
            else
              return true if valid_domain?
            end

            fail!(Bitbucket::MESSAGES[:invalid_domain])
            false
          end

          def authenticate!
            user = Doorman::User.where(:username.in => Bitbucket.configuration[:token].emails).first

            if user.nil?
              fail!(Doorman::MESSAGES[:login_bad_credentials])
            elsif !user.confirmed
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

          def valid_domain?
            emails = Bitbucket.configuration[:token].emails || []
            domains = Bitbucket.configuration[:domains].split(',')

            emails.each do |email|
              return true unless domains.detect { |domain| email.end_with?(domain) }.nil?
            end
            false
          end

          def token_link(action, token)
            "http://#{env['HTTP_HOST']}/doorman/#{action}/#{token}"
          end
        end
      end
    end
  end
end
