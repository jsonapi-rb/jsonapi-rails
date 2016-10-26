require 'jsonapi/renderer'
require 'jsonapi/serializable/model'

module JSONAPI
  module Rails
    module_function

    def render(resources, options)
      unless resources.respond_to?(:jsonapi_type)
        resources = serializable_resources_for(resources)
      end
      JSONAPI::Renderer.new(resources, options).as_json
    end

    def serializable_resources_for(resources)
      if resources.respond_to?(:each)
        resources.map { |r| serializable_model_for(r) }
      else
        serializable_model_for(resources)
      end
    end

    def serializable_model_for(model)
      serializable_klass_for(model).new(model: model)
    end

    def serializable_klass_for(model)
      # TODO(beauby): Move resource inference on class level in
      #   jsonapi-serializable.
      JSONAPI::Serializable::Model.new.resource_klass_for(model.class)
    end
  end
end
