require 'jsonapi/deserializable'

module JSONAPI
  module Rails
    PARSER = lambda do |body|
      data = JSON.parse(body)
      hash = { _jsonapi: data }

      hash.with_indifferent_access
    end
  end
end
