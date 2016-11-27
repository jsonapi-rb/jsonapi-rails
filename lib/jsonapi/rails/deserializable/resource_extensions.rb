require 'jsonapi/deserializable/resource'

module JSONAPI
  module Deserializable
    class Resource
      has_one do |key, _value, id, type|
        { "#{key}_id".to_sym => id,
          "#{key}_type".to_sym => type.singularize.camelize }
      end
      has_many do |key, _value, ids, types|
        key = key.singularize
        { "#{key}_ids".to_sym => ids,
          "#{key}_type".to_sym => types.map { |t| t.singularize.camelize } }
      end
    end
  end
end
