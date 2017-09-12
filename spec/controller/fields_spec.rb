require 'rails_helper'

describe ActionController::Base, type: :controller do
  with_model :User, scope: :all do
    table do |t|
      t.string :name
      t.string :email
    end
  end

  with_serializable :SerializableUser, scope: :all do
    type 'users'
    attributes :name, :email
  end

  before :all do
    User.create(name: 'Lucas', email: 'lucas@jsonapi-rb.org')
  end

  context 'when using default configuration' do
    controller do
      def index
        render jsonapi: User.all
      end
    end

    subject { JSON.parse(response.body) }

    it 'serializes all fields' do
      get :index

      expect(subject['data'][0]['attributes'].keys)
        .to match_array(%w[name email])
    end
  end

  context 'when using a custom configuration' do
    controller do
      def index
        render jsonapi: User.all
      end
    end

    subject { JSON.parse(response.body) }

    it 'modifies serialized fields' do
      with_config(jsonapi_fields: ->() { { users: [:name] } }) do
        get :index
      end

      expect(subject['data'][0]['attributes'].keys)
        .to match_array(%w[name])
    end
  end

  context 'when customizing jsonapi_fields hook' do
    controller do
      def index
        render jsonapi: User.all
      end

      def jsonapi_fields
        { users: [:name] }
      end
    end

    subject { JSON.parse(response.body) }

    it 'modifies serialized fields' do
      get :index

      expect(subject['data'][0]['attributes'].keys)
        .to match_array(%w[name])
    end
  end

  context 'when prividing fields renderer option' do
    controller do
      def index
        render jsonapi: User.all,
               fields: { users: [:email] }
      end
    end

    subject { JSON.parse(response.body) }

    it 'modifies serialized fields' do
      get :index

      expect(subject['data'][0]['attributes'].keys)
        .to match_array(%w[email])
    end
  end
end
