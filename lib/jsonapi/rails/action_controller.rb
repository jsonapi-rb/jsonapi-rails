require 'jsonapi/deserializable'
require 'jsonapi/parser'

module JSONAPI
  module Rails
    module ActionController
      REVERSE_MAPPING_KEY = 'jsonapi_deserializable.reverse_mapping'.freeze

      module ClassMethods
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
            controller.request.env[REVERSE_MAPPING_KEY] =
              resource.reverse_mapping
            controller.params[key.to_sym] = resource.to_hash
          end
        end
      end
    end
  end
end
