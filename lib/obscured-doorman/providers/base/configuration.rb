module Obscured
  module Doorman
    module Providers
      class BaseConfiguration
        def self.config_option(name)
          define_method(name) do
            read_value(name)
          end

          define_method("#{name}=") do |value|
            set_value(name, value)
          end
        end

        # Name of the authentication provider
        config_option :provider
        # Enables/disables the provider
        config_option :enabled

        # Provider client id
        config_option :client_id
        # Provider client secret
        config_option :client_secret
        # Provider scopes
        config_option :scopes

        # Provider authentication endpoint
        config_option :authorize_url
        # Provider token endpoint
        config_option :token_url
        # Provider login endpoint
        config_option :login_url
        # Provider redirect endpoint
        config_option :redirect_url

        # Authentication domains to login
        config_option :domains
        # Authentication token
        config_option :token


        attr_reader :defaults


        def [](key)
          read_value(key)
        end

        def []=(key, value)
          set_value(key, value)
        end



        private
        def read_value(name)
          if @config_values.has_key?(name)
            @config_values[name]
          else
            @defaults.send(name)
          end
        end

        def set_value(name, value)
          @config_values[name] = value
        end
      end
    end
  end
end