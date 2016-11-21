class SerializableTweet < JSONAPI::Serializable::Resource
  type 'tweets'

  attribute :content
  attribute(:date) { @object.created_at }

  has_one :parent
  has_one :author
end
