# frozen_string_literal: true

module Obscured
  module Doorman
    class Error < StandardError
      attr_reader :code
      attr_reader :field
      attr_reader :error

      ERRORS = {
        invalid_api_method: 'No method parameter was supplied',
        unspecified_error: 'Unspecified error',
        already_exists: '{what}',
        does_not_exist: '{what}',
        does_not_match: '{what}',
        account: '{what}',
        invalid_date: 'Cannot parse {what} from: {date}',
        invalid_type: '{what}',
        not_active: 'Not active',
        required_field_missing: 'Required field {field} is missing'
      }.freeze

      def initialize(code, params = {})
        field = params.delete(:field)
        error = params.delete(:error)

        super(parse(code, params))
        @code = code || :unspecified_error
        @field = field || :unspecified_field
        @error = error
      end

      private

      def parse(code, params = {})
        message = ERRORS[code]
        params.each_pair do |key, value|
          message = message.sub("{#{key}}", value)
        end
        message
      end
    end
  end
end
