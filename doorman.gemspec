# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'doorman/version'

Gem::Specification.new do |gem|
  gem.name          = 'doorman'
  gem.version       = Obscured::Doorman::VERSION
  gem.authors       = ['Erik Hennerfors']
  gem.email         = ['erik.hennerfors@adeprimo.se']
  gem.description   = %q{}
  gem.summary       = %q{}
  gem.homepage      = 'https://github.com/gonace/Obscured.Doorman.git'

  gem.required_ruby_version = '>= 2.4.2'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'geocoder'
  gem.add_dependency 'haml'
  gem.add_dependency 'mail'
  gem.add_dependency 'mongoid'
  gem.add_dependency 'rack'
  gem.add_dependency 'rack-contrib'
  gem.add_dependency 'rest-client'
  gem.add_dependency 'sinatra'
  #gem.add_dependency 'sinatra-contrib'
  gem.add_dependency 'sinatra-flash'
  gem.add_dependency 'sinatra-partial'
  gem.add_dependency 'warden'
end