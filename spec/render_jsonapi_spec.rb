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
          attribute :name

          def jsonapi_cache_key(*)
            'foo'
          end
        end
      end

      def index
        user = OpenStruct.new(id: 1, name: 'Lucas')

        render jsonapi: user,
               class: { OpenStruct: serializer },
               cache: Rails.cache
      end
    end

    subject { JSON.parse(response.body) }

    it 'renders a JSON API success document' do
      get :index
      expect(Rails.cache.exist?('foo')).to be true
      get :index

      expect(response.content_type).to eq('application/vnd.api+json')
      expect(subject.key?('data')).to be true
    end
  end
end
