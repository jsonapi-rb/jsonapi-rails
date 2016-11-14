require 'jsonapi/renderer'
require 'jsonapi/serializable/resource_builder'

module JSONAPI
  module Rails
    module_function

    def render(resources, options)
      # TODO(beauby): handle explicit SerializableModel class via options.
      # TODO(beauby): handle lightweight inference via :namespace option.
      # TODO(beauby): handle status option.
      inferer = options[:inferer]
      expose = options[:expose] || {}
      expose[:_resource_inferer] ||= inferer
      resources = ResourceBuilder.build(resources, expose, inferer)

      JSONAPI.render(options.merge(data: resources))
    end

    def default_exposures
      { url_helpers: ::Rails.application.routes.url_helpers }
    end

    def render_errors(errors, options)
      # TODO(beauby): SerializableError inference on AR validation errors.
      JSONAPI.render(options.merge(errors: errors))
    end
  end
end
