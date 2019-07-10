# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'obscured-doorman/version'

Gem::Specification.new do |gem|
  gem.name          = 'obscured-doorman'
  gem.version       = Obscured::Doorman::VERSION
  gem.authors       = ['Erik Hennerfors']
  gem.email         = ['erik.hennerfors@obscured.se']
  gem.description   = "Doorman is a front of Warden used by Obscured and it's applications"
  gem.summary       = "Doorman is a front of Warden used by Obscured and it's applications"
  gem.homepage      = 'https://github.com/gonace/Obscured.Doorman.git'

  gem.required_ruby_version = '>= 2'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'bcrypt'
  gem.add_dependency 'geocoder'
  gem.add_dependency 'haml'
  gem.add_dependency 'mail'
  gem.add_dependency 'mongoid'
  gem.add_dependency 'rack'
  gem.add_dependency 'rack-contrib'
  gem.add_dependency 'rest-client'
  gem.add_dependency 'sinatra'
  gem.add_dependency 'sinatra-contrib'
  gem.add_dependency 'sinatra-flash'
  gem.add_dependency 'sinatra-partial'
  gem.add_dependency 'warden'

  gem.add_development_dependency 'dotenv'
  gem.add_development_dependency 'factory_bot'
  gem.add_development_dependency 'rack-test'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'
end
