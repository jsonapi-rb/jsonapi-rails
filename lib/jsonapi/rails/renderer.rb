require 'jsonapi/serializable/renderer'

module JSONAPI
  module Rails
    # @private
    class SuccessRenderer
      def initialize(renderer = JSONAPI::Serializable::Renderer.new)
        @renderer = renderer

        freeze
      end

      def render(resources, options, controller)
        options = default_options(options, controller, resources)

        @renderer.render(resources, options)
      end

      private

      def default_options(options, controller, resources)
        options.dup.tap do |opts|
          opts[:class] ||= controller.jsonapi_class
          if (pagination_links = controller.jsonapi_pagination(resources))
            opts[:links] = (opts[:links] || {}).merge(pagination_links)
          end
          opts[:expose]  = controller.jsonapi_expose.merge(opts[:expose] || {})
          opts[:jsonapi] = opts.delete(:jsonapi_object) ||
                           controller.jsonapi_object
        end
      end
    end

    # @private
    class ErrorsRenderer
      def initialize(renderer = JSONAPI::Serializable::Renderer.new)
        @renderer = renderer

        freeze
      end

      def render(errors, options, controller)
        options = default_options(options, controller)

        errors = [errors] unless errors.is_a?(Array)

        @renderer.render_errors(errors, options)
      end

      private

      def default_options(options, controller)
        options.dup.tap do |opts|
          opts[:class] ||= controller.jsonapi_errors_class
          opts[:expose] =
            controller.jsonapi_expose
                      .merge(opts[:expose] || {})
                      .merge!(_jsonapi_pointers: controller.jsonapi_pointers)
          opts[:jsonapi] = opts.delete(:jsonapi_object) ||
                           controller.jsonapi_object
        end
      end
    end
  end
end
