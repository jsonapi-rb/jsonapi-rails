require 'rails_helper'

describe ActionController::Base, type: :controller do
  with_model :User, scope: :all do
    table do |t|
      t.string :name
      t.string :email
    end
  end

  with_model :Post, scope: :all do
    table do |t|
      t.string :title
      t.string :content
      t.references :author
    end

    model do
      belongs_to :author, class_name: 'User'
    end
  end

  with_serializable :SerializableUser, scope: :all do
    type 'users'
    attributes :name, :email
  end

  with_serializable :SerializablePost, scope: :all do
    type 'posts'
    attributes :title, :content
    belongs_to :author
  end

  before :all do
    user = User.create(name: 'Lucas', email: 'lucas@jsonapi-rb.org')
    Post.create(title: 'Hello', content: 'Nice post', author: user)
  end

  context 'when using default configuration' do
    controller do
      def index
        render jsonapi: Post.all
      end
    end

    subject { JSON.parse(response.body) }

    it 'does not include any related resource' do
      get :index

      expect(subject['included']).to be_nil
    end
  end

  context 'when using a custom configuration' do
    controller do
      def index
        render jsonapi: Post.all
      end
    end

    subject { JSON.parse(response.body) }

    it 'modifies serialized include' do
      with_config(jsonapi_include: ->() { 'author' }) do
        get :index
      end

      expect(subject['included'][0]['type']).to eq('users')
    end
  end

  context 'when customizing jsonapi_include hook' do
    controller do
      def index
        render jsonapi: Post.all
      end

      def jsonapi_include
        'author'
      end
    end

    subject { JSON.parse(response.body) }

    it 'modifies serialized fields' do
      get :index

      expect(subject['included'][0]['type']).to eq('users')
    end
  end

  context 'when prividing include renderer option' do
    controller do
      def index
        render jsonapi: Post.all, include: 'author'
      end
    end

    subject { JSON.parse(response.body) }

    it 'modifies serialized fields' do
      get :index

      expect(subject['included'][0]['type']).to eq('users')
    end
  end
end
