require 'jsonapi/deserializable/resource'

module JSONAPI
  module Rails
    # Customized deserializable resource class to match ActiveRecord's API.
    class DeserializableResource < JSONAPI::Deserializable::Resource
      id
      type
      attributes
      has_one do |_rel, id, type, key|
        type = type.to_s.singularize.camelize
        { "#{key}_id".to_sym => id, "#{key}_type".to_sym => type }
      end
      has_many do |_rel, ids, types, key|
        key   = key.to_s.singularize
        types = types.map { |t| t.to_s.singularize.camelize }
        { "#{key}_ids".to_sym => ids, "#{key}_types".to_sym => types }
      end
    end
  end
end
