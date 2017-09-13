module JSONAPI
  module Rails
    # @private
    module Logging
      def logger
        config[:logger]
      end
    end
  end
end
