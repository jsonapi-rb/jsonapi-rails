require 'rails/railtie'
require 'action_controller'
require 'active_support'

require 'jsonapi/rails/parser'
require 'jsonapi/rails/renderer'

module JSONAPI
  module Rails
    class Railtie < ::Rails::Railtie
      MEDIA_TYPE = 'application/vnd.api+json'.freeze
      RENDERERS = {
        jsonapi:       SuccessRenderer.new,
        jsonapi_error: ErrorsRenderer.new
      }.freeze

      initializer 'jsonapi-rails.action_controller' do
        ActiveSupport.on_load(:action_controller) do
          require 'jsonapi/rails/action_controller'
          include ::JSONAPI::Rails::ActionController

          Mime::Type.register MEDIA_TYPE, :jsonapi

          if ::Rails::VERSION::MAJOR >= 5
            ::ActionDispatch::Request.parameter_parsers[:jsonapi] = PARSER
          else
            ::ActionDispatch::ParamsParser::DEFAULT_PARSERS[Mime[:jsonapi]] = PARSER
          end

          ::ActionController::Renderers.add(:jsonapi) do |resources, options|
            self.content_type ||= Mime[:jsonapi]

            # Renderer proc is evaluated in the controller context, so it
            # has access to the jsonapi_pagination method.
            if (pagination_links = jsonapi_pagination(resources))
              (options[:links] ||= {}).merge!(pagination_links)
            end

            RENDERERS[:jsonapi].render(resources, options).to_json
          end

          ::ActionController::Renderers.add(:jsonapi_error) do |errors, options|
            # Renderer proc is evaluated in the controller context, so it
            # has access to the jsonapi_pointers method.
            options = options.merge(_jsonapi_pointers: jsonapi_pointers)
            self.content_type ||= Mime[:jsonapi]

            RENDERERS[:jsonapi_error].render(errors, options).to_json
          end
        end
      end
    end
  end
end
