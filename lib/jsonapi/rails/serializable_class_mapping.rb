module JSONAPI
  module Rails
    # @private
    class SerializableClassMapping < Hash
      def initialize(mapper, default_mappings = {})
        super() do |hash, class_name_sym|
          hash[class_name_sym] =
            mapper.call(class_name_sym.to_s)
        end.merge!(default_mappings)
      end
    end
  end
end
