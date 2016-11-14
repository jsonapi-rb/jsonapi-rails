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
        JSONAPI_KEYS = %w(data meta links jsonapi).freeze
        def initialize(app, key, klass)
          @app = app
          @deserializable_key = key
          @deserializable_class = klass
        end

        def call(env)
          request = Rack::Request.new(env)
          body = request.params.slice(*JSONAPI_KEYS)
          parser.parse!(body)
          deserialized_hash = @deserializable_class.call(body)
          jsonapi = {}
          JSONAPI_KEYS.each do |key|
            next unless request.params.key?(key)
            jsonapi[key.to_sym] = request.delete_param(key)
          end
          request.update_param(:_jsonapi, jsonapi)
          request.update_param(@deserializable_key, deserialized_hash)

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
