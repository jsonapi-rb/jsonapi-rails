module JSONAPI
  module Rails
    class ActiveModelError
      def initialize(field, message, source)
        @field   = field
        @message = message
        @source  = source

        freeze
      end

      def as_jsonapi
        {}.tap do |hash|
          hash[:detail] = @message
          hash[:title]  = "Invalid #{@field}" unless @field.nil?
          hash[:source] = { pointer: @source } unless @source.nil?
        end
      end
    end

    class ActiveModelErrors
      def initialize(errors, reverse_mapping)
        @errors = errors
        @reverse_mapping = reverse_mapping

        freeze
      end

      def to_a
        @errors.keys.flat_map do |key|
          @errors.full_messages_for(key).map do |message|
            ActiveModelError.new(key, message, @reverse_mapping[key])
          end
        end
      end
      alias to_array to_a
    end
  end
end
