require 'rails_helper'

describe ActionController::Base, type: :controller do
  describe '.deserializable_resource' do
    controller do
      deserializable_resource :user

      def create
        render plain: 'ok'
      end
    end

    let(:payload) do
      {
        _jsonapi: {
          'data' => {
            'type' => 'users',
            'attributes' => { 'foo' => 'bar', 'bar' => 'baz' }
          }
        }
      }
    end

    it 'makes the deserialized resource available in params' do
      post :create, params: payload

      expected = { 'type' => 'users', 'foo' => 'bar', 'bar' => 'baz' }
      expect(controller.params[:user]).to eq(expected)
    end

    it 'makes the deserialization mapping available via #jsonapi_pointers' do
      post :create, params: payload

      expected = { foo: '/data/attributes/foo',
                   bar: '/data/attributes/bar',
                   type: '/data/type' }
      expect(controller.jsonapi_pointers).to eq(expected)
    end
  end

  describe '#render jsonapi:' do
    controller do
      def index
        serializer = Class.new(JSONAPI::Serializable::Resource) do
          type :users
          attribute :name
        end
        user = OpenStruct.new(id: 1, name: 'Lucas')

        render jsonapi: user, class: serializer
      end
    end

    subject { JSON.parse(response.body) }
    let(:serialized_user) do
      {
        'data' => {
          'id' => '1',
          'type' => 'users',
          'attributes' => { 'name' => 'Lucas' }
        }
      }
    end

    it 'renders a JSON API document' do
      get :index

      expect(response.content_type).to eq('application/vnd.api+json')
      is_expected.to eq(serialized_user)
    end
  end
end
