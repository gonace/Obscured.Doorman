module Obscured
  module Doorman
    class Warden::SessionSerializer
      def serialize(user)
        user.id
      end

      def deserialize(id)
        User.find(id)
      end
    end


    module Base
      module Helpers
        # Generates a flash message by trying to fetch a default message, if that fails just pass the message
        def notify(type, message)
          message = Obscured::Doorman::MESSAGES[message] if message.is_a?(Symbol)
          flash[type] = message
        end

        # Generates a url for confirm account or reset password
        def token_link(type, user)
          "http://#{env['HTTP_HOST']}/doorman/#{type}/#{user.confirm_token}"
        end
      end

      def self.registered(app)
        app.helpers Obscured::Doorman::Base::Helpers
        app.helpers Obscured::Doorman::Helpers

        # Enable Sessions
        app.set :sessions, true unless defined?(Rack::Session::Cookie)

        app.use Warden::Manager do |config|
          config.scope_defaults :default, action: '/doorman/unauthenticated'

          config.failure_app = lambda { |_env|
            notify :error, Obscured::Doorman[:auth_required]
            [302, { 'Location' => Obscured::Doorman.configuration.paths[:login] }, ['']]
          }
        end

        Warden::Manager.before_failure do |env, _opts|
          # Because authentication failure can happen on any request but
          # we handle it only under "post '/obscured-doorman/unauthenticated'",
          # we need o change request to POST
          env['REQUEST_METHOD'] = 'POST'
          # And we need to do the following to work with  Rack::MethodOverride
          env.each do |key, _value|
            env[key]['_method'] = 'post' if key == 'rack.request.form_hash'
          end
        end
        Warden::Strategies.add(:password, Doorman::Strategies::Password)

        app.get '/doorman/register/?' do
          redirect Obscured::Doorman.configuration.paths[:success] if authenticated?

          unless Obscured::Doorman.configuration.registration
            notify :error, :signup_disabled
            redirect Obscured::Doorman.configuration.paths[:login]
          end

          haml :register
        end

        app.post '/doorman/unauthenticated' do
          status 401
          session[:return_to] = env['warden.options'][:attempted_path] if session[:return_to].nil?
          redirect Obscured::Doorman.configuration.paths[:login]
        end

        app.post '/doorman/register' do
          redirect Obscured::Doorman.configuration.paths[:success] if authenticated?

          unless Obscured::Doorman.configuration.registration
            notify :error, :signup_disabled
            redirect Obscured::Doorman.configuration.paths[:login]
          end

          begin
            user = User.make(username: params[:user][:login], 
                             password: params[:user][:password],
                             confirmed: !Obscured::Doorman.configuration.confirmation)
            user.set_name(params[:user][:first_name], params[:user][:last_name])
            user.save
          rescue => e
            notify :error, e.message
            redirect back
          end

          notify :success, :signup_success
          Obscured::Doorman::Mailer.new(
            to: user.username,
            subject: 'Account activation request',
            text: "You have to activate your account (#{user.username}) before using this service. " + token_link('confirm', user),
            html: (haml :'/templates/account_activation', locals: { user: user.username, link: token_link('confirm', user) }, layout: false)
          ).deliver!

          redirect "/doorman/login?email=#{user.username}"
        end

        app.get '/doorman/confirm/:token/?' do
          redirect Obscured::Doorman.configuration.paths[:success] if authenticated?

          if params[:token].nil? || params[:token].empty?
            notify :error, :confirm_no_token
            redirect '/'
          end

          user = User.where(confirm_token: params[:token]).first
          if user.nil?
            notify :error, :confirm_no_user
          else
            user.confirm_email!
            notify :success, :confirm_success
          end
          redirect Obscured::Doorman.configuration.paths[:login]
        end

        app.get '/doorman/login/?' do
          redirect Obscured::Doorman.configuration.paths[:success] if authenticated?

          email = cookies[:email]
          email = params[:email] if email.nil?

          haml :login, locals: { email: email }
        end

        app.post '/doorman/login' do
          warden.authenticate(:password)

          # Set cookie
          cookies[:email] = params['user']['login']

          # Notify if there are any messages from Warden.
          notify :error, warden.message unless warden.message.blank?

          redirect(Obscured::Doorman.configuration.use_referrer && session[:return_to] ? session.delete(:return_to) : Obscured::Doorman.configuration.paths[:success])
        end

        app.get '/doorman/logout/?' do
          warden.logout(:default)
          notify :success, :logout_success

          redirect Obscured::Doorman.configuration.paths[:login]
        end
      end
    end


    class Middleware < Sinatra::Base
      helpers Sinatra::Cookies
      register Sinatra::Flash
      register Sinatra::Partial
      register Strategies::RememberMe
      register Strategies::ForgotPassword
      register Doorman::Base
      register Doorman::Providers::Bitbucket
      register Doorman::Providers::GitHub
    end
  end
end