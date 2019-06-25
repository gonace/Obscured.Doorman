module Obscured
  module Doorman
    module Providers
      module Bitbucket
        class AccessToken
          attr_accessor :access_token
          attr_accessor :refresh_token
          attr_accessor :scopes
          attr_accessor :expires_in
          attr_accessor :expires_date
          attr_accessor :emails

          def initialize(attributes={})
            @access_token = attributes[:access_token]
            @refresh_token = attributes[:refresh_token]
            @scopes = attributes[:scopes]
            @expires_in = attributes[:expires_in]
            @expires_date = DateTime.now + self.expires_in.to_i.seconds
            @emails = attributes[:emails]
          end
        end
      end
    end
  end
end