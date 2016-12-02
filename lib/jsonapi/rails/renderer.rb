require 'jsonapi/serializable/renderer'

module JSONAPI
  module Rails
    class SuccessRenderer
      def self.render(resources, options)
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

    module_function

    # @api private
    def rails_renderer(renderer)
      proc do |json, options|
        json = renderer.render(json, options) unless json.is_a?(String)
        self.content_type ||= Mime[:jsonapi]
        self.response_body = json
      end
    end
  end
end
