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
            user.confirm
            fail!(Doorman::MESSAGES[:login_not_confirmed])
          else
            success!(user)
          end
        end
      end
    end
  end
end
