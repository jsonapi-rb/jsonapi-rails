require 'jsonapi/deserializable'
require 'jsonapi/parser'

module JSONAPI
  module Rails
    module Deserializable
      class Resource < JSONAPI::Deserializable::Resource
        id
        type
        attributes
        has_one do |_rel, id, type, key|
          type = type.to_s.singularize.camelize
          { "#{key}_id".to_sym => id, "#{key}_type".to_sym => type }
        end
        has_many do |_rel, ids, types, key|
          key   = key.to_s.singularize
          types = types.map { |t| t.to_s.singularize.camelize }
          { "#{key}_ids".to_sym => ids, "#{key}_types".to_sym => types }
        end
      end
    end

    module ActionController
      extend ActiveSupport::Concern

      JSONAPI_POINTERS_KEY = 'jsonapi_deserializable.jsonapi_pointers'.freeze

      class_methods do
        def deserializable_resource(key, options = {}, &block)
          options = options.dup
          klass = options.delete(:class) ||
                  Class.new(JSONAPI::Rails::Deserializable::Resource, &block)

          before_action(options) do |controller|
            hash = controller.params[:_jsonapi].to_unsafe_hash
            JSONAPI::Parser::Resource.parse!(hash)
            resource = klass.new(hash[:data])
            controller.request.env[JSONAPI_POINTERS_KEY] =
              resource.reverse_mapping
            controller.params[key.to_sym] = resource.to_hash
          end
        end
      end

      def jsonapi_expose
        {
          url_helpers: ::Rails.application.routes.url_helpers
        }
      end

      def jsonapi_pagination(_collection)
        nil
      end

      def jsonapi_pointers
        request.env[JSONAPI_POINTERS_KEY]
      end
    end
  end
end
