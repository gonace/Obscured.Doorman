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

require 'doorman/version'
require 'doorman/configuration'
require 'doorman/errors'
require 'doorman/domain/entity'
require 'doorman/domain/history'
require 'doorman/providers/bitbucket'
require 'doorman/providers/github'
require 'doorman/strategies/password'
require 'doorman/strategies/forgot_password'
require 'doorman/strategies/remember_me'
require 'doorman/utilities/hash'
require 'doorman/utilities/titles'
require 'doorman/utilities/roles'
require 'doorman/utilities/types'
require 'doorman/helpers'
require 'doorman/mailer'
require 'doorman/messages'
require 'doorman/base'


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

        require 'doorman/user'
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