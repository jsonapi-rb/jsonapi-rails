require 'jsonapi/rails/active_model_errors'
require 'jsonapi/serializable/renderer'

module JSONAPI
  module Rails
    class SuccessRenderer
      def initialize(renderer = JSONAPI::Serializable::SuccessRenderer.new)
        @renderer = renderer

        freeze
      end

      def render(resources, options, controller)
        options = options.dup

        if (pagination_links = controller.jsonapi_pagination(resources))
          (options[:links] ||= {}).merge!(pagination_links)
        end
        options[:expose]  =
          controller.jsonapi_expose.merge!(options[:expose] || {})
        options[:jsonapi] =
          options[:jsonapi_object] || controller.jsonapi_object

        @renderer.render(resources, options)
      end
    end

    class ErrorsRenderer
      def initialize(renderer = JSONAPI::Serializable::ErrorsRenderer.new)
        @renderer = renderer

        freeze
      end

      def render(errors, options, controller)
        options = options.merge(_jsonapi_pointers: controller.jsonapi_pointers)
        # TODO(beauby): SerializableError inference on AR validation errors.

        errors = [errors] unless errors.is_a?(Array)
        errors = errors.flat_map do |error|
          if error.respond_to?(:as_jsonapi)
            error
          elsif error.is_a?(ActiveModel::Errors)
            ActiveModelErrors.new(error, options[:_jsonapi_pointers]).to_a
          else
            raise # TODO(lucas): Raise meaningful exception.
          end
        end

        @renderer.render(errors, options)
      end
    end
  end
end
