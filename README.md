<a href="https://snyk.io/test/github/gonace/obscured.doorman"><img src="https://snyk.io/test/github/gonace/obscured.doorman/badge.svg" alt="Known Vulnerabilities" data-canonical-src="https://snyk.io/test/github/gonace/obscured.doorman" style="max-width:100%;"></a>
[![Build Status](https://travis-ci.org/gonace/Obscured.Doorman.svg?branch=master)](https://travis-ci.org/gonace/Obscured.Doorman)
[![Test Coverage](https://codeclimate.com/github/gonace/Obscured.Doorman/badges/coverage.svg)](https://codeclimate.com/github/gonace/Obscured.Doorman)
[![Code Climate](https://codeclimate.com/github/gonace/Obscured.Doorman/badges/gpa.svg)](https://codeclimate.com/github/gonace/Obscured.Doorman)

# Obscured::Doorman

## Requirements
- geocoder
- haml
- mongoid
- sinatra
- sinatra-contrib
- sinatra-flash
- sinatra-partial
- rack
- rack-contrib
- rest-client
- warden

## Installation
1. Add this line to your application's Gemfile:
```ruby
gem 'obscured-doorman', :git => 'git@github.com:gonace/Obscured.Doorman.git', :branch => 'master'
```

2. Execute:
```
$ bundle
```

3. Require the library in your application:
```ruby
require 'obscured-doorman'
```

### Example
There are example html- and mail-templates in /example, look at these to get your started.

## Configuration
The default configuration requires a mongoid client named :doorman, this will save users in a collection named 'users'
```ruby
Obscured::Doorman.setup do |cfg|
  cfg.registration    = false
  cfg.confirmation    = false
end
```

### Optional Configuration & Overrides
```ruby
Obscured::Doorman.setup do |cfg|
  ...
  cfg.providers       = [
    Obscured::Doorman::Providers::Bitbucket.setup do |c|
      c.enabled         = nil
      c.client_id       = nil
      c.client_secret   = nil
      c.domains   = nil
    end,
    Obscured::Doorman::Providers::GitHub.setup do |c|
      c.enabled         = nil
      c.client_id       = nil
      c.client_secret   = nil
      c.domains   = nil
    end
  ]
  ...
end
```


### All possible configurations
These values are representing the default values as well as all possible configurations.

```ruby
Obscured::Doorman.setup do |cfg|
  cfg.registration    = false
  cfg.confirmation    = false
  cfg.db_name         = 'doorman'
  cfg.db_collection   = 'users'
  cfg.db_client       = :doorman,
  cfg.mtp_domain      = 'doorman.local'
  cfg.smtp_server     = '127.0.0.1'
  cfg.smtp_username   = nil
  cfg.smtp_password   = nil
  cfg.smtp_port       = 25
  cfg.remember_cookie = 'sinatra.doorman.remember'
  cfg.remember_for    = 30
  cfg.use_referrer    = true
  cfg.providers       = [
    Obscured::Doorman::Providers::Bitbucket.setup do |c|
      c.enabled         = false
      c.client_id       = nil
      c.client_secret   = nil
      c.domains         = nil
    end,
    Obscured::Doorman::Providers::GitHub.setup do |c|
      c.enabled         = false
      c.client_id       = nil
      c.client_secret   = nil
      c.domains         = nil
    end
  ],
  cfg.paths = {
    :success => '/home',
    :login   => '/doorman/login',
    :logout  => '/doorman/logout',
    :forgot  => '/doorman/forgot',
    :reset   => '/doorman/reset'
  }
)
```

## TODO
- Rewrite some parts to keep the gem dependencies down.
    - Rewrite to drop dependencies to rest-client.