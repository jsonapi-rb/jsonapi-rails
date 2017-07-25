require 'rails/railtie'
require 'action_controller'
require 'active_support'

require 'jsonapi/rails/parser'
require 'jsonapi/rails/renderer'
require 'jsonapi/rails/controller'

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
          include ::JSONAPI::Rails::Controller

          Mime::Type.register MEDIA_TYPE, :jsonapi

          if ::Rails::VERSION::MAJOR >= 5
            ::ActionDispatch::Request.parameter_parsers[:jsonapi] = PARSER
          else
            ::ActionDispatch::ParamsParser::DEFAULT_PARSERS[Mime[:jsonapi]] = PARSER
          end

          RENDERERS.each do |name, renderer|
            ::ActionController::Renderers.add(name) do |resources, options|
              # Renderer proc is evaluated in the controller context.
              self.content_type ||= Mime[:jsonapi]

              renderer.render(resources, options, self).to_json
            end
          end
        end
      end
    end
  end
end
