require 'jsonapi/deserializable'
require 'jsonapi/parser'

module JSONAPI
  module Rails
    module ActionController
      def self.included(base)
        base.class_eval do
          extend ClassMethods
          prepend InstanceMethods
        end
      end

      module ClassMethods
        def deserializable_resource(key, klass = nil, &block)
          if klass.nil?
            klass = Class.new(JSONAPI::Deserializable::Resource, &block)
          end
          @deserializable_key = key
          @deserializable_class = klass
          @deserializable_parser = JSONAPI::Parser::Resource
        end

        def deserializable_relationship(key, klass = nil, &block)
          if klass.nil?
            klass = Class.new(JSONAPI::Deserializable::Relationship, &block)
          end
          @deserializable_key = key
          @deserializable_class = klass
          @deserializable_parser = JSONAPI::Parser::Relationship
        end

        def deserializable_class
          @deserializable_class
        end

        def deserializable_key
          @deserializable_key
        end

        def deserializable_parser
          @deserializable_parser
        end
      end

      module InstanceMethods
        def params
          params = super
          key = self.class.deserializable_key
          return params if body.key?(key)
          parser = self.class.deserializable_parser
          return params unless parser

          parser.parse!(body)
          deserializable_class = self.class.deserializable_class

          params.merge!(key => deserializable_class.call(params))
        end
      end
    end
  end
end
