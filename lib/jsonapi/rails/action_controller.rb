require 'jsonapi/deserializable'
require 'jsonapi/parser'

module JSONAPI
  module Rails
    module ActionController
      extend ActiveSupport::Concern

      JSONAPI_POINTERS_KEY = 'jsonapi_deserializable.jsonapi_pointers'.freeze

      class_methods do
        def deserializable_resource(key, options = {}, &block)
          _deserializable(key, options,
                          JSONAPI::Deserializable::Resource, &block)
        end

        def deserializable_relationship(key, options = {}, &block)
          _deserializable(key, options,
                          JSONAPI::Deserializable::Relationship, &block)
        end

        # @api private
        def _deserializable(key, options, fallback, &block)
          options = options.dup
          klass = options.delete(:class) || Class.new(fallback, &block)

          before_action(options) do |controller|
            resource = klass.new(controller.params[:_jsonapi].to_unsafe_hash)
            controller.request.env[JSONAPI_POINTERS_KEY] =
              resource.reverse_mapping
            controller.params[key.to_sym] = resource.to_hash
          end
        end
      end

      def jsonapi_pointers
        request.env[JSONAPI_POINTERS_KEY]
      end
    end
  end
end
