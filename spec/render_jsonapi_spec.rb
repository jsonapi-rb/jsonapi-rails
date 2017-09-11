require 'rails_helper'

describe ActionController::Base, '#render', type: :controller do
  context 'when calling render jsonapi: user' do
    controller do
      def index
        serializer = Class.new(JSONAPI::Serializable::Resource) do
          type :users
          attribute :name
        end
        user = OpenStruct.new(id: 1, name: 'Lucas')

        render jsonapi: user, class: { OpenStruct: serializer }
      end
    end

    subject { JSON.parse(response.body) }
    let(:serialized_user) do
      {
        'data' => {
          'id' => '1',
          'type' => 'users',
          'attributes' => { 'name' => 'Lucas' }
        },
        'jsonapi' => { 'version' => '1.0' }
      }
    end

    it 'renders a JSON API success document' do
      get :index

      expect(response.content_type).to eq('application/vnd.api+json')
      is_expected.to eq(serialized_user)
    end
  end

  context 'when specifying a custom jsonapi object at controller level' do
    controller do
      def index
        render jsonapi: nil
      end

      def jsonapi_object
        { version: '2.0' }
      end
    end

    subject { JSON.parse(response.body) }
    let(:document) do
      {
        'data' => nil,
        'jsonapi' => { 'version' => '2.0' }
      }
    end

    it 'renders a JSON API success document' do
      get :index

      expect(response.content_type).to eq('application/vnd.api+json')
      is_expected.to eq(document)
    end
  end
end
