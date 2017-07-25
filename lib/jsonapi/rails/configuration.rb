module JSONAPI
  module Rails
    class Configuration < ActiveSupport::InheritableOptions; end

    DEFAULT_CONFIG = {
      register_parameter_parser: true,
      register_mime_type: true,
      register_renderers: true
    }.freeze

    def self.configure
      yield config
    end

    def self.config
      @config ||= JSONAPI::Rails::Configuration.new(DEFAULT_CONFIG)
    end
  end
end
