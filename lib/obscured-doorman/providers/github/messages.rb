# frozen_string_literal: true

module Obscured
  module Doorman
    module Providers
      module GitHub
        MESSAGES = {
          invalid_domain: 'The domain associated with your email address is not whitelisted, please contact system administrator.'
        }.freeze
      end
    end
  end
end
