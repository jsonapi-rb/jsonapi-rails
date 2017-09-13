require 'jsonapi/rails/controller/deserialization'
require 'jsonapi/rails/controller/hooks'

module JSONAPI
  module Rails
    # ActionController methods and hooks for JSON API deserialization and
    #   rendering.
    module Controller
      include Deserialization
      include Hooks
    end
  end
end
