require 'jsonapi/deserializable/resource'

module JSONAPI
  module Rails
    module Deserializable
      module ResourceExtensions
        def deserialize_has_one_rel!(rel, &block)
          id = rel['data'] && rel['data']['id']
          type = rel['data'] && rel['data']['type'].singularize.camelize
          instance_exec(rel, id, type, &block)
        end

        def deserialize_has_many_rel!(rel, &block)
          ids = rel['data'].map { |ri| ri['id'] }
          types = rel['data'].map { |ri| ri['type'].singularize.camelize }
          instance_exec(rel, ids, types, &block)
        end
      end
    end
  end

  module Deserializable
    class Resource
      prepend JSONAPI::Rails::Deserializable::ResourceExtensions
    end
  end
end
