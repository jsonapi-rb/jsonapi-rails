require 'jsonapi/deserializable'
require 'jsonapi/parser'

module JSONAPI
  module Rails
    module ActionController
      def self.included(base)
        base.class_eval do
          extend ClassMethods
        end
      end

      module ClassMethods
        def deserializable_resource(key, options = {}, &block)
          deserializable(key, JSONAPI::Deserializable::Resource,
                         options, &block)
        end

        def deserializable_relationship(key, options = {}, &block)
          deserializable(key, JSONAPI::Deserializable::Relationship,
                         options, &block)
        end

        # @api private
        def deserializable(key, fallback_class, options = {}, &block)
          options = options.dup
          klass = options.delete(:class) || Class.new(fallback_class, &block)
          use Deserialization, key, klass, options
        end
      end

      class Deserialization
        REQUEST_PARAMETERS_KEY =
          'action_dispatch.request.request_parameters'.freeze
        def initialize(app, key, klass)
          @app = app
          @deserializable_key   = key
          @deserializable_class = klass
        end

        def call(env)
          request = Rack::Request.new(env)
          body = JSON.parse(request.body.read)
          deserialized_hash = @deserializable_class.call(body)
          (env[REQUEST_PARAMETERS_KEY] ||= {}).tap do |request_parameters|
            request_parameters[@deserializable_key] = deserialized_hash
          end

          @app.call(env)
        end
      end
    end
  end
end
