module JSONAPI
  module Rails
    class ActiveModelError < Serializable::Error
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

    class ActiveModelErrors
      def initialize(exposures)
        @errors = exposures[:object]
        @reverse_mapping = exposures[:_jsonapi_pointers] || {}

        freeze
      end

      def to_a
        @errors.keys.flat_map do |key|
          @errors.full_messages_for(key).map do |message|
            ActiveModelError.new(field: key, message: message,
                                 pointer: @reverse_mapping[key])
          end
        end
      end
      alias to_array to_a
    end
  end
end
