require 'jsonapi/renderer'
require 'jsonapi/serializable/resource_builder'

module JSONAPI
  module Rails
    class Renderer
      def self.render(resources, options)
        new(resources, options).render
      end

      def initialize(resources, options)
        # TODO(beauby): handle status option.
        @resources  = resources
        @options    = options.dup
        @klass      = @options.delete(:class)
        @namespace  = @options.delete(:namespace)
        @inferer    = @options.delete(:inferer)
        @exposures  = @options.delete(:expose) || {}
        @exposures[:_resource_inferer] = namespace_inferer || @inferer
      end

      def render
        JSONAPI.render(jsonapi_params.merge(data: jsonapi_resources)).to_json
      end

      private

      def jsonapi_params
        @options
      end

      def jsonapi_resources
        toplevel_inferer = @klass || @inferer
        ResourceBuilder.build(@resources, @exposures, toplevel_inferer)
      end

      def namespace_inferer
        return nil unless @namespace
        proc do |klass|
          names = klass.name.split('::')
          klass = names.pop
          [@namespace, names, "Serializable#{klass}"].reject(&:nil?).join('::')
        end
      end

      def exposures
        default_exposures.merge!(@exposures)
      end

      def default_exposures
        { url_helpers: ::Rails.application.routes.url_helpers }
      end
    end

    class ErrorRenderer
      def self.render(errors, options)
        new(errors, options).render
      end

      def initialize(errors, options)
        @errors    = errors
        @options   = options.dup
      end

      def render
        # TODO(beauby): SerializableError inference on AR validation errors.
        JSONAPI.render(jsonapi_params.merge(errors: jsonapi_errors)).to_json
      end

      private

      def jsonapi_params
        @options
      end

      def jsonapi_errors
        @errors
      end
    end
  end
end
