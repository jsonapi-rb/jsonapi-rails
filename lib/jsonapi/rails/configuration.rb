require 'jsonapi/rails/serializable_active_model_errors'
require 'jsonapi/rails/serializable_error_hash'

module JSONAPI
  module Rails
    class Configuration < ActiveSupport::InheritableOptions; end
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
    }.freeze

    DEFAULT_JSONAPI_PAGINATION = ->(_) { nil }

    DEFAULT_CONFIG = {
      jsonapi_class: DEFAULT_JSONAPI_CLASS,
      jsonapi_errors_class: DEFAULT_JSONAPI_ERRORS_CLASS,
      jsonapi_object: DEFAULT_JSONAPI_OBJECT,
      jsonapi_expose: DEFAULT_JSONAPI_EXPOSE,
      jsonapi_pagination: DEFAULT_JSONAPI_PAGINATION
    }.freeze

    def self.configure
      yield config
    end

    def self.config
      @config ||= JSONAPI::Rails::Configuration.new(DEFAULT_CONFIG)
    end
  end
end
