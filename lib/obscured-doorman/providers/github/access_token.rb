module Obscured
  module Doorman
    module Providers
      module GitHub
        class AccessToken
          attr_accessor :access_token
          attr_accessor :token_type
          attr_accessor :scope
          attr_accessor :emails

          def initialize(attributes={})
            @access_token = attributes[:access_token]
            @token_type = attributes[:token_type]
            @scopes = attributes[:scopes]
            @emails = attributes[:emails]
          end
        end
      end
    end
  end
end