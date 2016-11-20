require 'jsonapi/serializable/renderer'

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
        if errors.is_a?(ActiveModel::Errors)
          errors = build_active_model_errors(errors, options[:_jsonapi_mapping])
        end
        JSONAPI::Serializable::ErrorRenderer.render(errors, options)
      end

      def self.build_active_model_errors(errors, mapping)
        error_class = Class.new(JSONAPI::Serializable::Error) do
          detail { @detail }
          source do
            path, name = @attribute
            pointer "#{path}/#{name}"
          end
        end
        errors.map! do |attr, error|
          attr = mapping[attr]
          error_class.new(attribute: attr, detail: error)
        end
      end
    end
  end
end
