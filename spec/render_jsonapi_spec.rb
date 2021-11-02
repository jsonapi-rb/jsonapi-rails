require 'rails_helper'

describe ActionController::Base, '#render', type: :controller do
  context 'when calling render jsonapi:' do
    controller do
      def index
        render jsonapi: nil
      end
    end

    subject { JSON.parse(response.body) }

    it 'renders a JSON API success document' do
      get :index

      expect(response.content_type).to eq('application/vnd.api+json')
      expect(subject.key?('data')).to be true
    end
  end

  context 'when using a cache' do
    controller do
      def serializer
        Class.new(JSONAPI::Serializable::Resource) do
          type 'users'
          attributes :id, :name, :dob

          def jsonapi_cache_key(*)
            'cache_key'
          end
        end
      end

      def user
        OpenStruct.new(id: 1, name: 'Johnny Cache', dob: Time.utc(2021,1,1))
      end

      def index
        render jsonapi: [user],
               class: { OpenStruct: serializer }
      end

      def index_with_caching
        render jsonapi: [user],
               class: { OpenStruct: serializer },
               cache: Rails.cache
      end
    end

    before do
      routes.draw do
        get "index_with_caching" => "anonymous#index_with_caching"
        get "index" => "anonymous#index"
      end
    end

    let(:rendered_json) { JSON.parse(response.body) }

    it 'renders a JSON API success document' do
      get :index_with_caching

      expect(response.content_type).to eq('application/vnd.api+json')
      expect(rendered_json.key?('data')).to be true
    end

    it 'caches resources' do
      get :index_with_caching

      expect(Rails.cache.exist?('cache_key')).to be true
      expect(JSON.parse(Rails.cache.read('cache_key'))).to eq rendered_json['data'].first
    end

    it 'renders equivalent JSON whether caching or not' do
      expected_response = {
        "data"=>[{"id"=>"1", "type"=>"users", "attributes"=>{"id"=>1, "name"=>"Johnny Cache", "dob"=>"2021-01-01T00:00:00.000Z"}}],
        "jsonapi"=>{"version"=>"1.0"}
      }

      get :index
      response_with_no_caching = rendered_json.deep_dup

      get :index_with_caching
      response_with_caching = rendered_json

      expect(response_with_no_caching).to eq expected_response
      expect(response_with_caching).to eq expected_response
    end
  end
end
