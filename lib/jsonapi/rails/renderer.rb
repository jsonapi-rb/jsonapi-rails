require 'jsonapi/rails/active_model_errors'
require 'jsonapi/serializable/renderer'

module JSONAPI
  module Rails
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

      # @api private
      def default_options(options, controller, resources)
        options.dup.tap do |options|
          if (pagination_links = controller.jsonapi_pagination(resources))
            (options[:links] ||= {}).merge!(pagination_links)
          end
          options[:expose] = controller.jsonapi_expose
                               .merge!(options[:expose] || {})
          options[:jsonapi] =
            options[:jsonapi_object] || controller.jsonapi_object
        end
      end
    end

    class ErrorsRenderer
      def initialize(renderer = JSONAPI::Serializable::Renderer.new)
        @renderer = renderer

        freeze
      end

      def render(errors, options, controller)
        options = default_options(options, controller)

        errors = [errors] unless errors.is_a?(Array)
        errors = errors.flat_map do |error|
          if error.is_a?(ActiveModel::Errors)
            translate_activemodel_errors(error, options)
          else
            error
          end
        end

        @renderer.render_errors(errors, options)
      end

      private

      # @api private
      def translate_activemodel_errors(errors, options)
        klass = if options[:inferrer] &&
                   options[:inferrer].key?(:'ActiveModel::Errors')
                  options[:inferrer][:'ActiveModel::Errors']
                else
                  JSONAPI::Rails::ActiveModelErrors
                end
        klass = klass.safe_constantize if klass.is_a?(String)

        klass.new(options[:expose].merge(object: errors)).to_a
      end

      # @api private
      def default_options(options, controller)
        options.dup.tap do |options|
          options[:expose] =
            controller.jsonapi_expose
              .merge!(options[:expose] || {})
              .merge!(_jsonapi_pointers: controller.jsonapi_pointers)
          options[:jsonapi] =
            options[:jsonapi_object] || controller.jsonapi_object
        end
      end
    end
  end
end
