require 'rails/railtie'
require 'action_controller'
require 'active_support'

require 'jsonapi/rails/parser'
require 'jsonapi/rails/renderer'

module JSONAPI
  module Rails
    class Railtie < ::Rails::Railtie
      MEDIA_TYPE = 'application/vnd.api+json'.freeze
      PARSER = JSONAPI::Rails.parser.freeze
      RENDERERS = {
        jsonapi: JSONAPI::Rails.success_renderer,
        jsonapi_errors: JSONAPI::Rails.error_renderer
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

          RENDERERS.each do |key, renderer|
            ::ActionController::Renderers.add(key, &renderer)
          end
        end
      end
    end
  end
end
