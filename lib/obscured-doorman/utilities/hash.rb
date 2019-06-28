# frozen_string_literal: true

module Obscured
  module Doorman
    class ConfigurationHash < Hash
      include HashRecursiveMerge

      def respond_to_missing?(name, include_private)
        # ...
        # TODO: Fix this
      end

      def method_missing(meth, *args, &block)
        key?(meth) ? self[meth] : super
      end
    end
  end
end
