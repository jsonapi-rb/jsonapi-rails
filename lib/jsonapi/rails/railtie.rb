require 'rails/railtie'
require 'action_controller'
require 'active_support'

require 'jsonapi/rails/configuration'
require 'jsonapi/rails/parser'
require 'jsonapi/rails/renderer'

module JSONAPI
  module Rails
    class Railtie < ::Rails::Railtie
      MEDIA_TYPE = 'application/vnd.api+json'.freeze
      PARSER = JSONAPI::Rails.parser
      RENDERERS = {
        jsonapi:       JSONAPI::Rails.rails_renderer(SuccessRenderer),
        jsonapi_error: JSONAPI::Rails.rails_renderer(ErrorRenderer)
      }.freeze

      initializer 'jsonapi-rails.action_controller' do
        ActiveSupport.on_load(:action_controller) do
          require 'jsonapi/rails/action_controller'
          include ::JSONAPI::Rails::ActionController

          if JSONAPI::Rails.config.register_mime_type
            Mime::Type.register MEDIA_TYPE, :jsonapi
          end

          if JSONAPI::Rails.config.register_parameter_parser
            if ::Rails::VERSION::MAJOR >= 5
              ::ActionDispatch::Request.parameter_parsers[:jsonapi] = PARSER
            else
              ::ActionDispatch::ParamsParser::DEFAULT_PARSERS[Mime[:jsonapi]] = PARSER
            end
          end

          if JSONAPI::Rails.config.register_renderers
            RENDERERS.each do |key, renderer|
              ::ActionController::Renderers.add(key, &renderer)
            end
          end

          JSONAPI::Deserializable::Resource.configure do |config|
            config.default_has_one do |key, _rel, id, type|
              key  = key.to_s.singularize
              type = type.to_s.singularize.camelize
              { "#{key}_id".to_sym => id, "#{key}_type".to_sym => type }
            end

            config.default_has_many do |key, _rel, ids, types|
              key   = key.to_s.singularize
              types = types.map { |t| t.to_s.singularize.camelize }
              { "#{key}_ids".to_sym => ids, "#{key}_types".to_sym => types }
            end
          end
        end
      end
    end
  end
end
