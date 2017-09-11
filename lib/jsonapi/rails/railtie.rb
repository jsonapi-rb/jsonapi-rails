require 'rails/railtie'
require 'action_controller'
require 'active_support'

require 'jsonapi/rails/renderer'

module JSONAPI
  module Rails
    # @private
    class Railtie < ::Rails::Railtie
      MEDIA_TYPE = 'application/vnd.api+json'.freeze
      PARSER = lambda do |body|
        data = JSON.parse(body)
        hash = { _jsonapi: data }

        hash.with_indifferent_access
      end
      RENDERERS = {
        jsonapi:        SuccessRenderer.new,
        jsonapi_errors: ErrorsRenderer.new
      }.freeze

      initializer 'jsonapi-rails.init' do
        register_mime_type
        register_parameter_parser
        register_renderers
        ActiveSupport.on_load(:action_controller) do
          require 'jsonapi/rails/controller'
          include ::JSONAPI::Rails::Controller
        end
      end

      private

      def register_mime_type
        Mime::Type.register(MEDIA_TYPE, :jsonapi)
      end

      def register_parameter_parser
        if ::Rails::VERSION::MAJOR >= 5
          ActionDispatch::Request.parameter_parsers[:jsonapi] = PARSER
        else
          ActionDispatch::ParamsParser::DEFAULT_PARSERS[Mime[:jsonapi]] = PARSER
        end
      end

      # rubocop:disable Metrics/MethodLength
      def register_renderers
        ActiveSupport.on_load(:action_controller) do
          RENDERERS.each do |name, renderer|
            ::ActionController::Renderers.add(name) do |resources, options|
              # Renderer proc is evaluated in the controller context.
              self.content_type ||= Mime[:jsonapi]

              ActiveSupport::Notifications.instrument('render.jsonapi',
                                                      resources: resources,
                                                      options: options) do
                renderer.render(resources, options, self).to_json
              end
            end
          end
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
