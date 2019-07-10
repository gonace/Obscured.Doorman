# frozen_string_literal: true

module Obscured
  module Doorman
    module Strategies
      module ForgotPassword
        def self.registered(app)
          Warden::Manager.after_authentication do |user, auth, _opts|
            # If the user requested a new password,
            # but then remembers and logs in,
            # then invalidate password reset token
            user.remembered_password! if auth.winning_strategy.is_a?(Doorman::Strategies::Password)
          end

          app.get '/doorman/forgot/?' do
            redirect(Doorman.configuration.paths[:success]) if authenticated?

            email = cookies[:email]
            email = params[:email] if email.nil?

            haml :forgot, locals: { email: email }
          end

          app.post '/doorman/forgot' do
            redirect(Doorman.configuration.paths[:success]) if authenticated?
            redirect(Doorman.configuration.paths[:login]) unless params[:user]

            user = User.where(username: params[:user][:username]).first
            if user.nil?
              notify :error, :forgot_no_user
              redirect(back)
            else
              if user.role.to_sym == Doorman::Roles::SYSTEM
                notify :error, :reset_system_user
                redirect(Doorman.configuration.paths[:forgot])
              end

              token = user.forgot_password!
              if token.nil? && !token&.type.eql?(:password)
                notify :error, :token_not_found
                redirect(back)
              end
              if token&.used?
                notify :error, :token_used
                redirect(back)
              end

              if File.exist?('views/doorman/templates/password_reset.haml')
                template = haml :'/templates/password_reset', layout: false, locals: {
                  user: user.username,
                  link: token_link('reset', token.token)
                }
                Doorman::Mailer.new(
                  to: user.username,
                  subject: 'Password change request',
                  text: "We have received a password change request for your account (#{user.username}). " + token_link('reset', token.token),
                  html: template
                ).deliver!
              else
                Doorman.logger.warn "Template not found (views/doorman/templates/password_reset.haml), account password reset at #{token_link('reset', token.token)}"
              end

              notify :success, :forgot_success
              redirect(Doorman.configuration.paths[:login])
            end
          end

          app.get '/doorman/reset/:token/?' do
            redirect Doorman.configuration.paths[:success] if authenticated?

            if params[:token].nil? || params[:token].empty?
              notify :error, :token_not_found
              redirect(Doorman.configuration.paths[:login])
            end

            token = Token.where(token: params[:token]).first
            if token.nil?
              notify :error, :token_not_found
              redirect(Doorman.configuration.paths[:login])
            end
            if token&.used?
              notify :error, :token_used
              redirect(Doorman.configuration.paths[:login])
            end

            user = token&.user
            if user.nil?
              notify :error, :reset_no_user
              redirect(Doorman.configuration.paths[:login])
            end

            haml :reset, locals: { token: token, email: user&.username }
          end

          app.post '/doorman/reset' do
            redirect(Doorman.configuration.paths[:success]) if authenticated?
            redirect(Doorman.configuration.paths[:login]) unless params[:user]

            token = Token.where(token: params[:user][:token]).first
            if token.nil?
              notify :error, :token_not_found
              redirect(back)
            end
            if token&.used?
              notify :error, :token_used
              redirect(back)
            end

            user = token&.user
            if user.nil?
              notify :error, :reset_no_user
              redirect(Doorman.configuration.paths[:login])
            end

            if user&.role&.to_sym == Doorman::Roles::SYSTEM
              notify :error, :reset_system_user
              redirect(Doorman.configuration.paths[:login])
            end

            success = user&.reset_password!(
              params[:user][:password],
              params[:user][:token]
            )

            if success && File.exist?('views/doorman/templates/password_confirmation.haml')
              position = Geocoder.search(request.ip)
              template = haml :'/templates/password_confirmation', layout: false, locals: {
                user: user&.username,
                browser: "#{request&.browser} #{request&.browser_version}",
                location: "#{position&.first&.city},#{position&.first&.country}",
                ip: request&.ip,
                system: "#{request&.os} #{request&.os_version}"
              }
              Doorman::Mailer.new(
                to: user&.username,
                subject: 'Password change confirmation',
                text: "The password for your account (#{user&.username}) was recently changed. This change was made from the following device or browser from: ",
                html: template
              ).deliver!
            else
              Doorman.logger.warn "Template not found (views/doorman/templates/password_confirmation.haml) The password for your account (#{user&.username}) was recently changed."

              notify :error, :reset_unmatched_passwords
              redirect(Doorman.configuration.paths[:login])
            end

            user&.confirm!
            warden.set_user(user)
            notify :success, :reset_success

            redirect(Doorman.configuration.use_referrer && session[:return_to] ? session.delete(:return_to) : Doorman.configuration.paths[:success])
          end
        end
      end
    end
  end
end
