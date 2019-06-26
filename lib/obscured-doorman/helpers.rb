module Obscured
  module Doorman
    module Helpers
      # The main accessor to the warden middleware
      def warden
        request.env['warden']
      end

      # Check the current session is authenticated to a given scope
      def authenticated?(scope = nil)
        scope ? warden.authenticated?(scope: scope) : warden.authenticated?
      end
      alias logged_in? authenticated?

      # Authenticate a user against defined strategies
      def authenticate(*args)
        warden.authenticate!(*args)
      end
      alias login authenticate

      # Return session info
      #
      # @param [Symbol] scope the scope to retrieve session info for
      def session_info(scope = nil)
        scope ? warden.session(scope) : scope
      end

      # Terminate the current session
      #
      # @param [Symbol] scopes the session scope to terminate
      def logout(scopes = nil)
        scopes ? warden.logout(scopes) : warden.logout(warden.config.default_scope)
      end

      # Access the user from the current session
      #
      # @param [Symbol] scope for the logged in user
      def user(scope = nil)
        scope ? warden.user(scope) : warden.user
      end
      alias current_user user

      # Require authorization for an action
      #
      # @param [String] failure_path path to redirect to if user is unauthenticated
      def authorize!(failure_path = nil)
        unless authenticated?
          session[:return_to] = request.path if Doorman.configuration.use_referrer
          redirect(failure_path || Doorman.configuration.paths[:login])
        end
      end

      # Require authorization for example ajax calls, returns 403 is not authenticated
      #
      # @param [Symbol] format
      def authorized?(format = :json)
        unless authenticated?
          if format == :json
            halt 403, { 'Content-Type' => 'application/json' }, { message: 'Unauthorized' }.to_json
          end
          halt 403
        end
      end
    end
  end
end