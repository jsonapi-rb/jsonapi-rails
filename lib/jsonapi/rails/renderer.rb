require 'jsonapi/rails/active_model_errors'
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
        opts[:jsonapi] = opts.delete(:jsonapi_object)

        JSONAPI::Serializable::Renderer.render(resources, opts)
      end
    end

    class ErrorsRenderer
      def self.render(errors, options)
        errors = [errors] unless errors.is_a?(Array)
        errors = errors.flat_map do |error|
          if error.respond_to?(:as_jsonapi)
            error
          elsif error.is_a?(ActiveModel::Errors)
            ActiveModelErrors.new(error, options[:_reverse_mapping]).to_a
          elsif error.is_a?(Hash)
            JSONAPI::Serializable::Error.create(error)
          else
            raise # TODO(lucas): Raise meaningful exception.
          end
        end

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
