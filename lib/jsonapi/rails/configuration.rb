require 'jsonapi/rails/serializable_active_model_errors'
require 'jsonapi/rails/serializable_error_hash'

module JSONAPI
  module Rails
    class Configuration < ActiveSupport::InheritableOptions; end

    # @private
    module Configurable
      DEFAULT_JSONAPI_CLASS = Hash.new do |h, k|
        names = k.to_s.split('::')
        klass = names.pop
        h[k] = [*names, "Serializable#{klass}"].join('::').safe_constantize
      end.freeze

      DEFAULT_JSONAPI_ERRORS_CLASS = DEFAULT_JSONAPI_CLASS.dup.merge!(
        'ActiveModel::Errors'.to_sym =>
        JSONAPI::Rails::SerializableActiveModelErrors,
        'Hash'.to_sym => JSONAPI::Rails::SerializableErrorHash
      ).freeze

      DEFAULT_JSONAPI_OBJECT = {
        version: '1.0'
      }.freeze

      DEFAULT_JSONAPI_EXPOSE = lambda {
        { url_helpers: ::Rails.application.routes.url_helpers }
      }

      DEFAULT_JSONAPI_FIELDS = ->() { nil }

      DEFAULT_JSONAPI_INCLUDE = ->() { nil }

      DEFAULT_JSONAPI_LINKS = ->() { {} }

      DEFAULT_JSONAPI_PAGINATION = ->(_) { {} }

      DEFAULT_CONFIG = {
        jsonapi_class: DEFAULT_JSONAPI_CLASS,
        jsonapi_errors_class: DEFAULT_JSONAPI_ERRORS_CLASS,
        jsonapi_expose:  DEFAULT_JSONAPI_EXPOSE,
        jsonapi_fields:  DEFAULT_JSONAPI_FIELDS,
        jsonapi_include: DEFAULT_JSONAPI_INCLUDE,
        jsonapi_links:   DEFAULT_JSONAPI_LINKS,
        jsonapi_object:  DEFAULT_JSONAPI_OBJECT,
        jsonapi_pagination: DEFAULT_JSONAPI_PAGINATION
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
