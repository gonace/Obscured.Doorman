require 'bcrypt'
require 'geocoder'
require 'haml'
require 'mail'
require 'mongoid'
require 'sinatra'
require 'sinatra/contrib'
require 'sinatra/flash'
require 'sinatra/partial'
require 'rack'
require 'rack/contrib'
require 'rack/contrib/cookies'
require 'rest-client'
require 'warden'

require 'obscured-doorman/configuration'
require 'obscured-doorman/errors'
require 'obscured-doorman/providers/bitbucket'
require 'obscured-doorman/providers/github'
require 'obscured-doorman/strategies/password'
require 'obscured-doorman/strategies/forgot_password'
require 'obscured-doorman/strategies/remember_me'
require 'obscured-doorman/utilities/hash'
require 'obscured-doorman/utilities/roles'
require 'obscured-doorman/utilities/types'
require 'obscured-doorman/helpers'
require 'obscured-doorman/mailer'
require 'obscured-doorman/messages'
require 'obscured-doorman/version'
require 'obscured-doorman/base'


module Obscured
  module Doorman
    class << self
      # Configuration Object (instance of Obscured::Doorman::Configuration)
      attr_writer :configuration
      # Logger
      attr_writer :logger

      ##
      # Configuration options should be set by passing a hash:
      #
      #   Obscured::Doorman.setup do |cfg|
      #     cfg.confirmation   = false,
      #     cfg.registration   = true,
      #     cfg.smtp_domain    = 'domain.tld',
      #     cfg.smtp_username  = 'username',
      #     cfg.smtp_password  = 'password',
      #   end
      #
      def setup
        yield(configuration)

        require 'obscured-doorman/token'
        require 'obscured-doorman/user'
      end

      def configuration
        @configuration ||= Configuration.new
      end

      def default_configuration
        configuration.defaults
      end

      def logger
        log = Logger.new(STDOUT)
        log.level = Logger::DEBUG
        log
      end
    end
  end
end