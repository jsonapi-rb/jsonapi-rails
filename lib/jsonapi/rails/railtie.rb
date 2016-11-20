require 'rails/railtie'
require 'action_controller'
require 'active_support'

module JSONAPI
  module Rails
    class Railtie < ::Rails::Railtie
      MEDIA_TYPE = 'application/vnd.api+json'.freeze
      require 'jsonapi/rails/parser'
      PARSER = JSONAPI::Rails.parser

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

          require 'jsonapi/rails/renderer'
          ::ActionController::Renderers.add :jsonapi do |json, options|
            unless json.is_a?(String)
              json = JSONAPI::Rails::Renderer.render(json, options)
            end
            self.content_type ||= Mime[:jsonapi]
            self.response_body = json
          end

          ::ActionController::Renderers.add :jsonapi_errors do |json, options|
            unless json.is_a?(String)
              json = JSONAPI::Rails::ErrorRenderer.render(json, options)
            end
            self.content_type ||= Mime[:jsonapi]
            self.response_body = json
          end
        end
      end
    end
  end
end
