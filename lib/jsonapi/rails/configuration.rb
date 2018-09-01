require 'jsonapi/rails/serializable_active_model_errors'
require 'jsonapi/rails/serializable_error_hash'

module JSONAPI
  module Rails
    class Configuration < ActiveSupport::InheritableOptions; end

    # @private
    module Configurable
      DEFAULT_JSONAPI_CLASS_MAPPER = -> (class_name) do
        names = class_name.to_s.split('::')
        klass = names.pop
        [*names, "Serializable#{klass}"].join('::').safe_constantize
      end

      DEFAULT_JSONAPI_CLASS_MAPPINGS = {}.freeze

      DEFAULT_JSONAPI_ERROR_CLASS_MAPPINGS = {
        :'ActiveModel::Errors' => JSONAPI::Rails::SerializableActiveModelErrors,
        :Hash => JSONAPI::Rails::SerializableErrorHash
      }.freeze

      DEFAULT_JSONAPI_OBJECT = { version: '1.0' }.freeze

      DEFAULT_JSONAPI_CACHE = ->() { nil }

      DEFAULT_JSONAPI_EXPOSE = lambda {
        { url_helpers: ::Rails.application.routes.url_helpers }
      }

      DEFAULT_JSONAPI_FIELDS = ->() { nil }

      DEFAULT_JSONAPI_INCLUDE = ->() { nil }

      DEFAULT_JSONAPI_LINKS = ->() { {} }

      DEFAULT_JSONAPI_META = ->() { nil }

      DEFAULT_JSONAPI_PAGINATION = ->(_) { {} }

      DEFAULT_LOGGER = Logger.new(STDERR)

      DEFAULT_CONFIG = {
        jsonapi_class_mapper: DEFAULT_JSONAPI_CLASS_MAPPER,
        jsonapi_class_mappings: DEFAULT_JSONAPI_CLASS_MAPPINGS,
        jsonapi_errors_class_mapper: nil,
        jsonapi_errors_class_mappings: DEFAULT_JSONAPI_ERROR_CLASS_MAPPINGS,
        jsonapi_cache:   DEFAULT_JSONAPI_CACHE,
        jsonapi_expose:  DEFAULT_JSONAPI_EXPOSE,
        jsonapi_fields:  DEFAULT_JSONAPI_FIELDS,
        jsonapi_include: DEFAULT_JSONAPI_INCLUDE,
        jsonapi_links:   DEFAULT_JSONAPI_LINKS,
        jsonapi_meta:    DEFAULT_JSONAPI_META,
        jsonapi_object:  DEFAULT_JSONAPI_OBJECT,
        jsonapi_pagination: DEFAULT_JSONAPI_PAGINATION,
        logger: DEFAULT_LOGGER
      }.freeze

      def configure
        yield config
      end

      def config
        @config ||= JSONAPI::Rails::Configuration.new(DEFAULT_CONFIG)
      end
    end
  end
end
