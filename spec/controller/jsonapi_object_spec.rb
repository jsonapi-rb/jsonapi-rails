require 'rails_helper'

describe ActionController::Base, type: :controller do
  context 'when using default configuration' do
    controller do
      def index
        render jsonapi: nil
      end
    end

    subject { JSON.parse(response.body) }

    it 'adds a jsonapi object' do
      get :index

      expect(subject['jsonapi']).to eq('version' => '1.0')
    end
  end

  context 'when using a custom configuration' do
    controller do
      def index
        render jsonapi: nil
      end
    end

    subject { JSON.parse(response.body) }

    it 'modifies jsonapi object' do
      with_config(jsonapi_object: { version: '2.0' }) do
        get :index
      end

      expect(subject['jsonapi']).to eq('version' => '2.0')
    end
  end

  context 'when customizing jsonapi_object hook' do
    controller do
      def index
        render jsonapi: nil
      end

      def jsonapi_object
        { version: '2.0' }
      end
    end

    subject { JSON.parse(response.body) }

    it 'modifies jsonapi object' do
      get :index

      expect(subject['jsonapi']).to eq('version' => '2.0')
    end
  end

  context 'when prividing fields renderer option' do
    controller do
      def index
        render jsonapi: nil, jsonapi_object: { version: '2.0' }
      end
    end

    subject { JSON.parse(response.body) }

    it 'modifies jsonapi object' do
      get :index

      expect(subject['jsonapi']).to eq('version' => '2.0')
    end
  end
end
