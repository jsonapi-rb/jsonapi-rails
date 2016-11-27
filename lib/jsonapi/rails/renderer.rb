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

    def success_renderer
      rails_renderer(SuccessRenderer)
    end

    def error_renderer
      rails_renderer(ErrorRenderer)
    end

    def rails_renderer(klass)
      proc do |json, options|
        json = klass.render(json, options) unless json.is_a?(String)
        self.content_type ||= Mime[:jsonapi]
        self.response_body = json
      end
    end
  end
end
