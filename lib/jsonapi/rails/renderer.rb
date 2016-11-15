require 'jsonapi/serializable/renderer'
require 'jsonapi/serializable/resource_builder'

module JSONAPI
  module Rails
    class Renderer
      def self.render(resources, options)
        # TODO(beauby): handle status option.
        opts = options.dup
        # TODO(beauby): Move this to a global configuration.
        default_exposures = {
          url_helpers: ::Rails.application.routes.url_helpers
        }
        opts[:expose] = default_exposures.merge!(opts[:expose] || {})

        JSONAPI::Serializable::Renderer.render(resources, opts)
      end
    end

    class ErrorRenderer
      def self.render(errors, options)
        # TODO(beauby): SerializableError inference on AR validation errors.
        JSONAPI::Serializable::ErrorRenderer.render(errors, options)
      end
    end
  end
end
