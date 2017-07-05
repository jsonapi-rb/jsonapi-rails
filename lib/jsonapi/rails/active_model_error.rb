module JSONAPI
  module Rails
    class ActiveModelError < JSONAPI::Serializable::Error
      def self.from_errors(errors, reverse_mapping)
        errors.keys.flat_map do |field|
          errors.full_messages_for(field).map do |message|
            new(field, message, reverse_mapping[field])
          end
        end
      end

      def initialize(field, message, source)
        super(field: field, message: message, source: source)
      end

      title { @field.present? ? "Invalid #{@field}" : 'Invalid record' }
      detail { @message }

      source do
        pointer @source unless @source.nil?
      end
    end
  end
end
