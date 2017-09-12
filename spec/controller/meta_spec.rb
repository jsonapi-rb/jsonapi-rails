require 'rails_helper'

describe ActionController::Base, type: :controller do
  context 'when using default configuration' do
    controller do
      def index
        render jsonapi: nil
      end
    end

    subject { JSON.parse(response.body) }

    it 'does not add meta' do
      get :index

      expect(subject.key?('meta')).to be false
    end
  end

  context 'when using a custom configuration' do
    controller do
      def index
        render jsonapi: nil
      end
    end

    subject { JSON.parse(response.body) }

    it 'modifies serialized meta' do
      with_config(jsonapi_meta: ->() { { foo: 'bar' } }) do
        get :index
      end

      expect(subject['meta']).to eq('foo' => 'bar')
    end
  end

  context 'when customizing jsonapi_meta hook' do
    controller do
      def index
        render jsonapi: nil
      end

      def jsonapi_meta
        { foo: 'bar' }
      end
    end

    subject { JSON.parse(response.body) }

    it 'modifies serialized meta' do
      get :index

      expect(subject['meta']).to eq('foo' => 'bar')
    end
  end

  context 'when prividing meta renderer option' do
    controller do
      def index
        render jsonapi: nil, meta: { foo: 'bar' }
      end
    end

    subject { JSON.parse(response.body) }

    it 'modifies serialized meta' do
      get :index

      expect(subject['meta']).to eq('foo' => 'bar')
    end
  end
end
