require 'jsonapi/renderer'
require 'jsonapi/serializable/resource_builder'

module JSONAPI
  module Rails
    class Renderer
      # NOTE(beauby): It might be worth splitting this class into two,
      #   with an ErrorRenderer.
      def self.render(resources, options)
        new(resources, options).render
      end

      def self.render_errors(errors, options)
        new(errors, options).render_errors
      end

      def initialize(resources, options)
        # TODO(beauby): handle explicit SerializableModel class via options.
        # TODO(beauby): handle lightweight inference via :namespace option.
        # TODO(beauby): handle status option.
        @resources  = resources
        @options    = options.dup
        @inferer    = @options.delete(:inferer)
        @exposures  = @options.delete(:expose) || {}
        @exposures[:_resource_inferer] ||= @inferer
      end

      def render
        JSONAPI.render(jsonapi_params.merge(data: jsonapi_resources))
      end

      def render_errors
        # TODO(beauby): SerializableError inference on AR validation errors.
        JSONAPI.render(jsonapi_params.merge(errors: jsonapi_resources))
      end

      private

      def jsonapi_resources
        ResourceBuilder.build(@resources, @exposures, @inferer)
      end

      def jsonapi_params
        @errors
      end

      def exposures
        default_exposures.merge!(@exposures)
      end

      def default_exposures
        { url_helpers: ::Rails.application.routes.url_helpers }
      end
    end
  end
end
