module JSONAPI
  module Rails
    class SerializableActiveModelError < Serializable::Error
      title do
        "Invalid #{@field}" unless @field.nil?
      end

      detail do
        @message
      end

      source do
        pointer @pointer unless @pointer.nil?
      end
    end

    class SerializableActiveModelErrors
      def initialize(exposures)
        @errors = exposures[:object]
        @reverse_mapping = exposures[:_jsonapi_pointers] || {}

        freeze
      end

      def as_jsonapi
        @errors.keys.flat_map do |key|
          @errors.full_messages_for(key).map do |message|
            SerializableActiveModelError.new(field: key, message: message,
                                             pointer: @reverse_mapping[key])
              .as_jsonapi
          end
        end
      end
    end
  end
end