# frozen_string_literal: true

$LOAD_PATH.unshift File.dirname(__FILE__)
require 'factory_bot'
require 'pp'
require 'rspec'
require 'simplecov'

SimpleCov.start

# pull in the code
Dir.glob('./spec/helpers/*.rb').sort.each(&method(:require))
Dir.glob('./spec/matchers/*.rb').sort.each(&method(:require))
Dir.glob('./lib/*.rb').sort.each(&method(:require))

Mongoid.load!(File.join(File.dirname(__FILE__), '/config/mongoid.yml'), 'spec')
Mongo::Logger.logger.level = Logger::ERROR

Obscured::Doorman.setup do |cfg|
  cfg.db_client = :default
  cfg.db_name = 'doorman_testing'
end

RSpec.configure do |c|
  c.include FactoryBot::Syntax::Methods
  c.include Obscured::Doorman::Spec::Helpers
  c.include Warden::Test::Helpers
  c.include Warden::Test::Mock

  c.filter_run_excluding integration: true
  c.filter_run_excluding broken: true

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