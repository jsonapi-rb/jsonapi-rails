require 'jsonapi/serializable/renderer'

module JSONAPI
  module Rails
    class SuccessRenderer
      def initialize(renderer = JSONAPI::Serializable::SuccessRenderer.new)
        @renderer = renderer

        freeze
      end

      def render(resources, options)
        @renderer.render(resources, options)
      end
    end

    class ErrorsRenderer
      def initialize(renderer = JSONAPI::Serializable::ErrorsRenderer.new)
        @renderer = renderer

        freeze
      end

      def render(errors, options)
        # TODO(beauby): SerializableError inference on AR validation errors.
        @renderer.render(errors, options)
      end
    end
  end
end
