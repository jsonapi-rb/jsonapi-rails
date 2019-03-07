require 'rails_helper'

describe ActionController::Base, '.deserializable_resource',
         type: :controller do
  let(:payload) do
    {
      _jsonapi: {
        'data' => {
          'type' => 'users',
          'attributes' => { 'name' => 'Lucas' }
        }
      }
    }
  end

  context 'when using default deserializer' do
    controller do
      deserializable_resource :user

      def create
        render plain: 'ok'
      end
    end

    it 'makes the deserialized resource available in params' do
      post :create, params: payload

      expected = { 'type' => 'users', 'name' => 'Lucas' }
      expect(controller.params[:user]).to eq(expected)
    end

    it 'makes the deserialization mapping available via #jsonapi_pointers' do
      post :create, params: payload

      expected = { name: '/data/attributes/name',
                   type: '/data/type' }
      expect(controller.jsonapi_pointers).to eq(expected)
    end
  end

  context 'when using a customized deserializer' do
    controller do
      deserializable_resource :user do
        attribute(:name) do |val|
          { 'first_name'.to_sym => val }
        end
      end

      def create
        render plain: 'ok'
      end
    end

    it 'makes the deserialized resource available in params' do
      post :create, params: payload

      expected = { 'type' => 'users', 'first_name' => 'Lucas' }
      expect(controller.params[:user]).to eq(expected)
    end

    it 'makes the deserialization mapping available via #jsonapi_pointers' do
      post :create, params: payload

      expected = { first_name: '/data/attributes/name',
                   type: '/data/type' }
      expect(controller.jsonapi_pointers).to eq(expected)
    end
  end

  context 'when using a customized deserializer with key_format' do
    controller do
      deserializable_resource :user do
        key_format(&:capitalize)
      end

      def create
        render plain: 'ok'
      end
    end

    it 'makes the deserialized resource available in params' do
      post :create, params: payload

      expected = { 'type' => 'users', 'Name' => 'Lucas' }
      expect(controller.params[:user]).to eq(expected)
    end

    it 'makes the deserialization mapping available via #jsonapi_pointers' do
      post :create, params: payload

      expected = { Name: '/data/attributes/name',
                   type: '/data/type' }
      expect(controller.jsonapi_pointers).to eq(expected)
    end
  end

  context 'when unable to deserialize resource from params' do
    controller do
      deserializable_resource :user

      def create
        render plain: :ok
      end
    end

    context 'with the default config' do
      it 'makes the deserialized resource available in params' do
        post :create

        expect(response.body).to eq(
          {
            :errors => [
              {
                :links => {
                :about => "http://jsonapi.org/format/"
              },
              :title => "Non-compliant Request Body",
              :detail => "The request was not formatted in compliance with the application/vnd.api+json spec"
              }
            ],
            :jsonapi => {
              :version=>"1.0"
            }
          }.to_json
        )
        expect(response).to be_bad_request
      end
    end

    context 'when the config[:jsonapi_payload_malformed] == nil' do
      it 'makes the deserialization mapping available via #jsonapi_pointers' do
        with_config(jsonapi_payload_malformed: nil) { post :create }

        expect(response.body).to eq('ok')
        expect(response).to be_success
      end
    end
  end
end
