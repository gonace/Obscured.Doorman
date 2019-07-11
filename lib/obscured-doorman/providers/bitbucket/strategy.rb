# frozen_string_literal: true

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
              user.confirm
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
        end
      end
    end
  end
end
