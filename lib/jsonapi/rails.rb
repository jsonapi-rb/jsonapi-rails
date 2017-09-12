require 'jsonapi/deserializable'
require 'jsonapi/serializable'
require 'jsonapi/rails/configuration'
require 'jsonapi/rails/railtie'

module JSONAPI
  module Rails
    extend Configurable
  end
end
