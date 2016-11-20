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
        def deserializable_resource(key, *args, &block)
          klass = args.shift unless args.first.is_a?(Hash)
          options = args.first || {}
          if klass.nil?
            klass = Class.new(JSONAPI::Deserializable::Resource, &block)
          end
          use DeserializeResource, key, klass, options
        end

        def deserializable_relationship(key, *args, &block)
          klass = args.shift unless args.first.is_a?(Hash)
          options = args.first || {}
          if klass.nil?
            klass = Class.new(JSONAPI::Deserializable::Relationship, &block)
          end
          use DeserializeResource, key, klass, options
        end
      end

      class DeserializationMiddleware
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
          parser.parse!(body)
          deserialized_hash = @deserializable_class.call(body)
          (env[REQUEST_PARAMETERS_KEY] ||= {}).tap do |request_parameters|
            request_parameters[@deserializable_key] = deserialized_hash
          end

          @app.call(env)
        end
      end

      class DeserializeResource < DeserializationMiddleware
        def parser
          JSONAPI::Parser::Resource
        end
      end

      class DeserializeRelationship < DeserializationMiddleware
        def parser
          JSONAPI::Parser::Relationship
        end
      end
    end
  end
end
