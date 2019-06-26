module Obscured
  module Doorman
    module Strategies
      module ForgotPassword
        def self.registered(app)
          Warden::Manager.after_authentication do |user, auth, _opts|
            # If the user requested a new password,
            # but then remembers and logs in,
            # then invalidate password reset token
            if auth.winning_strategy.is_a?(Doorman::Strategies::Password)
              user.remembered_password!
            end
          end

          app.get '/doorman/forgot/?' do
            redirect Doorman.configuration.paths[:success] if authenticated?

            email = cookies[:email]
            email = params[:email] if email.nil?

            haml :forgot, locals: { email: email }
          end

          app.post '/doorman/forgot' do
            redirect Doorman.configuration.paths[:success] if authenticated?
            redirect '/' unless params[:user]

            user = User.where(username: params[:user][:username]).first
            if user.nil?
              notify :error, :forgot_no_user
              redirect(back)
            else
              if user.role.to_sym == Doorman::Roles::SYSTEM
                notify :error, :reset_system_user
                redirect(Doorman.configuration.paths[:forgot])
              end

              user.forgot_password!

              template = haml :'/templates/password_reset', layout: false, locals: {
                user: user.username,
                link: token_link('reset', user)
              }
              Doorman::Mailer.new(
                to: user.username,
                subject: 'Password change request',
                text: "We have received a password change request for your account (#{user.username}). " + token_link('reset', user),
                html: template
              ).deliver!

              notify :success, :forgot_success
              redirect(Doorman.configuration.paths[:login])
            end
          end

          app.get '/doorman/reset/:token/?' do
            redirect Doorman.configuration.paths[:success] if authenticated?

            if params[:token].nil? || params[:token].empty?
              notify :error, :reset_no_token
              redirect '/'
            end

            token = Token.where(token: params[:token]).first
            if token.nil?
              notify :error, :reset_no_token
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
            redirect Doorman.configuration.paths[:success] if authenticated?
            redirect '/' unless params[:user]

            token = Token.where(token: params[:user][:token]).first
            if token.nil?
              notify :error, :reset_no_token
              redirect(Doorman.configuration.paths[:login])
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

            if success
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
              notify :error, :reset_unmatched_passwords
              redirect back
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