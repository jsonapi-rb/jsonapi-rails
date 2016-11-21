class SerializableUser < JSONAPI::Serializable::Resource
  type 'users'

  attribute :name
  attribute :email
  attribute :created_at
  attribute :updated_at

  has_many :tweets
end
