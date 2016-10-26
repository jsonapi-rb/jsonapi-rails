require 'jsonapi/serializable/model'

module JSONAPI
  module Rails
    module Serializable
      module ModelExtensions
        def initialize(params = {})
          params[:url_helpers] ||= ::Rails.application.routes.url_helpers
          super(params)
        end
      end
    end
  end

  module Serializable
    class Model
      prepend JSONAPI::Rails::Serializable::ModelExtensions
    end
  end
end
