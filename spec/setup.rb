# frozen_string_literal: true

# Pull in test utilities
require 'simplecov'
require 'factory_bot'
require 'mongoid'
require 'pp'
require 'rack/test'
require 'rspec'

# pull in the code
require_relative '../lib/obscured-doorman'

# pull in test helpers
Dir.glob('./spec/helpers/*.rb').sort.each(&method(:require))
Dir.glob('./spec/matchers/*.rb').sort.each(&method(:require))

Mongoid.load!(File.join(File.dirname(__FILE__), '/config/mongoid.yml'), 'spec')
Mongo::Logger.logger.level = Logger::ERROR

Obscured::Doorman.setup do |cfg|
  cfg.db_client = :default
  cfg.db_name = 'doorman_testing'
  cfg.registration = true
end

RSpec.configure do |c|
  c.order = :random
  c.filter_run :focus
  c.run_all_when_everything_filtered = true

  c.include FactoryBot::Syntax::Methods
  c.include Obscured::Doorman::Spec::Helpers
  c.include Warden::Test::Helpers
  c.include Warden::Test::Mock

  c.before(:suite) do
    FactoryBot.find_definitions
    Mongoid.purge!
  end

  c.before(:each) do
    Mongoid.purge!
  end

  c.after(:suite) do
    Mongoid.purge!
  end
end