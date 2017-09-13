require 'jsonapi/deserializable'
require 'jsonapi/serializable'
require 'jsonapi/rails/railtie'

module JSONAPI
  module Rails
    require 'jsonapi/rails/configuration'
    require 'jsonapi/rails/logging'

    extend Configurable
    extend Logging
  end
end
