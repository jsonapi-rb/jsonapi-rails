require 'jsonapi/parser'

module JSONAPI
  module Rails
    module_function

    def parser
      lambda do |body|
        data = JSON.parse(body)
        JSONAPI.parse_resource!(body)
        data = { _json: data } unless data.is_a?(Hash)
        data.with_indifferent_access
      end
    end
  end
end
