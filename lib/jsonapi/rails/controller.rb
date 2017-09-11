require 'jsonapi/deserializable'
require 'jsonapi/parser'
require 'jsonapi/rails/configuration'

module JSONAPI
  module Rails
    module Deserializable
      # @private
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

    # ActionController methods and hooks for JSON API deserialization and
    #   rendering.
    module Controller
      extend ActiveSupport::Concern

      JSONAPI_POINTERS_KEY = 'jsonapi-rails.jsonapi_pointers'.freeze

      class_methods do
        # Declare a deserializable resource.
        #
        # @param key [Symbol] The key under which the deserialized hash will be
        #   available within the `params` hash.
        # @param options [Hash]
        # @option class [Class] A custom deserializer class. Optional.
        # @option only List of actions for which deserialization should happen.
        #   Optional.
        # @option except List of actions for which deserialization should not
        #   happen. Optional.
        # @yieldreturn Optional block for in-line definition of custom
        #   deserializers.
        #
        # @example
        #   class ArticlesController < ActionController::Base
        #     deserializable_resource :article, only: [:create, :update]
        #
        #     def create
        #       article = Article.new(params[:article])
        #
        #       if article.save
        #         render jsonapi: article
        #       else
        #         render jsonapi_errors: article.errors
        #       end
        #     end
        #
        #     # ...
        #   end
        #
        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        def deserializable_resource(key, options = {}, &block)
          options = options.dup
          klass = options.delete(:class) ||
                  Class.new(JSONAPI::Rails::Deserializable::Resource, &block)

          before_action(options) do |controller|
            # TODO(lucas): Fail with helpful error message if _jsonapi not
            #   present.
            hash = controller.params[:_jsonapi].to_unsafe_hash
            ActiveSupport::Notifications
              .instrument('parse.jsonapi', payload: hash, class: klass) do
              JSONAPI::Parser::Resource.parse!(hash)
              resource = klass.new(hash[:data])
              controller.request.env[JSONAPI_POINTERS_KEY] =
                resource.reverse_mapping
              controller.params[key.to_sym] = resource.to_hash
            end
          end
        end
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
      end

      # Hook for serializable class mapping (for resources).
      # Overridden by the `class` renderer option.
      # @return [Hash{Symbol=>Class}]
      def jsonapi_class
        JSONAPI::Rails.config[:jsonapi_class].dup
      end

      # Hook for serializable class mapping (for errors).
      # Overridden by the `class` renderer option.
      # @return [Hash{Symbol=>Class}]
      def jsonapi_errors_class
        JSONAPI::Rails.config[:jsonapi_errors_class].dup
      end

      # Hook for the jsonapi object.
      # Overridden by the `jsonapi_object` renderer option.
      # @return [Hash]
      def jsonapi_object
        JSONAPI::Rails.config[:jsonapi_object]
      end

      # Hook for default exposures.
      # @return [Hash]
      def jsonapi_expose
        instance_exec(&JSONAPI::Rails.config[:jsonapi_expose])
      end

      # Hook for pagination scheme.
      # @return [Hash]
      def jsonapi_pagination(resources)
        instance_exec(resources, &JSONAPI::Rails.config[:jsonapi_pagination])
      end

      # JSON pointers for deserialized fields.
      # @return [Hash{Symbol=>String}]
      def jsonapi_pointers
        request.env[JSONAPI_POINTERS_KEY] || {}
      end
    end
  end
end
