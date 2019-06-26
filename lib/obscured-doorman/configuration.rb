module Obscured
  module Doorman
    class Configuration
      def self.config_option(name)
        define_method(name) do
          read_value(name)
        end

        define_method("#{name}=") do |value|
          set_value(name, value)
        end
      end

      def self.proc_config_option(name)
        define_method(name) do |&block|
          set_value(name, block) unless block.nil?
          read_value(name)
        end

        define_method("#{name}=") do |value|
          set_value(name, value)
        end
      end

      # Enables/disables user confirmation
      config_option :confirmation
      # Enables/disables user registration
      config_option :registration
      # Enables/disables the usage of referrer redirection
      config_option :use_referrer

      # Remember me cookie name
      config_option :remember_cookie
      # Remember me for x-days
      config_option :remember_for

      # Database name
      config_option :db_name
      # Database client
      config_option :db_client

      # SMTP Domain
      config_option :smtp_domain
      # SMTP Server
      config_option :smtp_server
      # SMTP Server PSort
      config_option :smtp_port
      # SMTP Sender Username
      config_option :smtp_username
      # SMTP Sender Password
      config_option :smtp_password

      # Authentication Providers
      config_option :providers

      # Authentication Providers
      config_option :paths


      attr_reader :defaults

      def initialize
        @config_values = {}

        # set default attribute values
        @defaults = _defaults
      end

      def [](key)
        read_value(key)
      end

      def []=(key, value)
        set_value(key, value)
      end


      private

      def read_value(name)
        if @config_values.key?(name)
          @config_values[name]
        else
          @defaults.send(name)
        end
      end

      def set_value(name, value)
        @config_values[name] = value
      end

      def _defaults
        OpenStruct.new(
          confirmation: false,
          registration: false,
          use_referrer: true,
          remember_cookie: 'sinatra.doorman.remember',
          remember_for: 30,
          db_name: 'doorman',
          db_client: :doorman,
          smtp_domain: 'doorman.local',
          smtp_server: '127.0.0.1',
          smtp_port: 587,
          smtp_username: nil,
          smtp_password: nil,
          providers: [],
          paths: {
            success: '/home',
            login: '/doorman/login',
            logout: '/doorman/logout',
            forgot: '/doorman/forgot',
            reset: '/doorman/reset',
            register: '/doorman/register'
          }
        )
      end
    end
  end
end