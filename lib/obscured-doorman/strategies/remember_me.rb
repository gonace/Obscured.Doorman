# frozen_string_literal: true

module Obscured
  module Doorman
    module Strategies
      class RememberMeStrategy < Warden::Strategies::Base
        def valid?
          !env['rack.cookies'][Doorman.configuration.remember_cookie].nil?
        end

        def authenticate!
          token = env['rack.cookies'][Doorman.configuration.remember_cookie]
          return unless token

          token = Token.where(token: token).first
          user = token&.user
          env['rack.cookies'].delete(Doorman.configuration.remember_cookie) && return if user.nil?
          success!(user)
        end
      end

      module RememberMe
        def self.registered(app)
          app.use Rack::Cookies

          Warden::Strategies.add(:remember_me, Strategies::RememberMeStrategy)

          app.before do
            warden.authenticate(:remember_me)
          end

          Warden::Manager.after_authentication do |user, auth, _opts|
            if auth.winning_strategy.is_a?(Strategies::RememberMeStrategy) ||
               (auth.winning_strategy.is_a?(Strategies::Password) && auth.params['user']['remember_me'])

              token = user.tokens.where(type: :remember).first
              user.remember_me! # new token
              auth.env['rack.cookies'][Doorman.configuration.remember_cookie] = {
                value: token,
                expires: (Time.now + Doorman.configuration.remember_for.days.seconds),
                path: '/'
              }
            end
          end

          Warden::Manager.before_logout do |user, auth, _opts|
            user&.forget_me! if user
            auth.env['rack.cookies'].delete(Doorman.configuration.remember_cookie)
          end
        end
      end
    end
  end
end
