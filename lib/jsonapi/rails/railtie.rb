require 'rails/railtie'
require 'action_controller'
require 'action_controller/railtie'
require 'active_support'

require 'jsonapi/rails/parser'
require 'jsonapi/rails/render'

module JSONAPI
  module Rails
    class Railtie < ::Rails::Railtie
      MEDIA_TYPE = 'application/vnd.api+json'.freeze
      HEADERS = {
        response: { 'CONTENT_TYPE'.freeze => MEDIA_TYPE },
        request:  { 'ACCEPT'.freeze => MEDIA_TYPE }
      }.freeze
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
            json = JSONAPI::Rails.render(json, options)
                                 .to_json(options)
          end
          self.content_type ||= Mime[:jsonapi]
          self.response_body = json
        end

        # TODO(beauby): Add renderer for `jsonapi_errors`.
      end
    end
  end
end

ActiveSupport.on_load(:action_controller) do
  include JSONAPI::Rails::ActionController
end
