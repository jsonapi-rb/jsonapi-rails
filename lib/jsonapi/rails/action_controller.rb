require 'jsonapi/deserializable'
require 'jsonapi/parser'

module JSONAPI
  module Rails
    module ActionController
      REVERSE_MAPPING_KEY = 'jsonapi_deserializable.reverse_mapping'.freeze

      def self.prepended(base)
        base.class_eval do
          extend ClassMethods
        end
      end

      def render(options = {})
        reverse_mapping = request.env[REVERSE_MAPPING_KEY]
        super(options.merge(_reverse_mapping: reverse_mapping))
      end

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
          use Deserialization, key, klass, options
        end
      end

      class Deserialization
        REQUEST_PARAMETERS_KEY =
          'action_dispatch.request.request_parameters'.freeze
        def initialize(app, key, klass)
          @app = app
          @deserializable_key = key
          @deserializable_class = klass
        end

        def call(env)
          request = Rack::Request.new(env)
          body = JSON.parse(request.body.read)
          deserializable = @deserializable_class.new(body)
          env[REVERSE_MAPPING_KEY] = deserializable.reverse_mapping
          (env[REQUEST_PARAMETERS_KEY] ||= {}).tap do |request_parameters|
            request_parameters[@deserializable_key] = deserializable.to_hash
          end

          @app.call(env)
        end
      end
    end
  end
end
