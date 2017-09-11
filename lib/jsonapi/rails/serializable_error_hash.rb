module JSONAPI
  module Rails
    # @private
    class SerializableErrorHash < JSONAPI::Serializable::Error
      def initialize(exposures)
        super
        exposures[:object].each do |k, v|
          instance_variable_set("@_#{k}", v)
        end
      end
    end
  end
end
