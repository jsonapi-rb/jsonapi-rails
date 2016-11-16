require 'rails/railtie'
require 'action_controller'
require 'action_controller/railtie'
require 'active_support'

require 'jsonapi/rails/parser'
require 'jsonapi/rails/renderer'

module JSONAPI
  module Rails
    class Railtie < ::Rails::Railtie
      MEDIA_TYPE = 'application/vnd.api+json'.freeze
      PARSER = JSONAPI::Rails.parser

      initializer 'JSONAPI::Rails.initialize' do
        Mime::Type.register MEDIA_TYPE, :jsonapi
        if ::Rails::VERSION::MAJOR >= 5
          ActionDispatch::Request.parameter_parsers[:jsonapi] = PARSER
        else
          ActionDispatch::ParamsParser::DEFAULT_PARSERS[Mime[:jsonapi]] = PARSER
        end

        ActionController::Renderers.add :jsonapi do |json, options|
          unless json.is_a?(String)
            json = JSONAPI::Rails::Renderer.render(json, options)
          end
          self.content_type ||= Mime[:jsonapi]
          self.response_body = json
        end

        ActionController::Renderers.add :jsonapi_errors do |json, options|
          unless json.is_a?(String)
            json = JSONAPI::Rails::ErrorRender.render_errors(json, options)
          end
          self.content_type ||= Mime[:jsonapi]
          self.response_body = json
        end
      end
    end
  end
end

ActiveSupport.on_load(:action_controller) do
  require 'jsonapi/rails/action_controller'
  include JSONAPI::Rails::ActionController
end
