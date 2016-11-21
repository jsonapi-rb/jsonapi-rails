class DeserializableTweet < JSONAPI::Deserializable::Resource
  id

  attribute :content

  has_one :parent do |rel, id, type|
    field parent_id: id
  end

  has_one :author do |rel, id, type|
    field author_id: id
  end
end
