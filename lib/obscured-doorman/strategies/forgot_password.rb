module Obscured
  module Doorman
    module Strategies
      module ForgotPassword
        def self.registered(app)
          Warden::Manager.after_authentication do |user, auth, opts|
            # If the user requested a new password,
            # but then remembers and logs in,
            # then invalidate password reset token
            if auth.winning_strategy.is_a?(Obscured::Doorman::Strategies::Password)
              user.remembered_password!
            end
          end

          app.get '/doorman/forgot/?' do
            redirect Obscured::Doorman.configuration.paths[:success] if authenticated?

            email = cookies[:email]
            if email.nil?
              email = params[:email] rescue ''
            end

            haml :forgot, :locals => {:email => email}
          end

          app.post '/doorman/forgot' do
            redirect Obscured::Doorman.configuration.paths[:success] if authenticated?
            redirect '/' unless params['user']

            user = User.get_by_username(params['user']['login'])
            if user.nil?
              notify :error, :forgot_no_user
              redirect back
            end
            if user.role.to_sym == Obscured::Doorman::Roles::SYSTEM
              notify :error, :reset_system_user
              redirect Obscured::Doorman.configuration.paths[:forgot]
            end

            user.forgot_password!
            Obscured::Doorman::Mailer.new({
              to: user.username,
              subject: 'Password change request',
              text: "We have received a password change request for your account (#{user.username}). " + token_link('reset', user),
              html: (haml :'/templates/password_reset', :locals => {:user => user.username, :link => token_link('reset', user)}, :layout => false)
            }).deliver!

            notify :success, :forgot_success
            redirect Obscured::Doorman.configuration.paths[:login]
          end

          app.get '/doorman/reset/:token/?' do
            redirect Obscured::Doorman.configuration.paths[:success] if authenticated?

            if params[:token].nil? || params[:token].empty?
              notify :error, :reset_no_token
              redirect '/'
            end

            user = User.where({:confirm_token => params[:token]}).first
            if user.nil?
              notify :error, :reset_no_user
              redirect Obscured::Doorman.configuration.paths[:login]
            end

            haml :reset, :locals => { :token => user.confirm_token, :email => user.username }
          end

          app.post '/doorman/reset' do
            redirect Obscured::Doorman.configuration.paths[:success] if authenticated?
            redirect '/' unless params['user']

            user = User.where({:confirm_token => params[:user][:token]}).first rescue nil
            if user.nil?
              notify :error, :reset_no_user
              redirect Obscured::Doorman.configuration.paths[:login]
            end
            if user.role.to_sym == Obscured::Doorman::Roles::SYSTEM
              notify :error, :reset_system_user
              redirect Obscured::Doorman.configuration.paths[:login]
            end

            success = user.reset_password!(
              params['user']['password'],
              params['user']['token']
            )

            unless success
              notify :error, :reset_unmatched_passwords
              redirect back
            else
              geo_position = Geocoder.search(request.ip)
              Obscured::Doorman::Mailer.new({
                to: user.username,
                subject: 'Password change confirmation',
                text: "The password for your account (#{user.username}) was recently changed. This change was made from the following device or browser from: ",
                html: (haml :'/templates/password_confirmation', :locals => {:user => user.username, :browser => "#{request.browser rescue nil} #{request.browser_version rescue nil}", :location => "#{geo_position.first.city rescue ''},#{geo_position.first.country rescue ''}", :ip => request.ip, :system => "#{request.os rescue nil} #{request.os_version rescue nil}"}, :layout => false)
              }).deliver!
            end

            user.confirm_email!
            warden.set_user(user)
            notify :success, :reset_success
            redirect Obscured::Doorman.configuration.use_referrer && session[:return_to] ? session.delete(:return_to) : Obscured::Doorman.configuration.paths[:success]
          end
        end
      end
    end
  end
end