require 'rails_helper'

describe ActionController::Base, type: :controller do
  context 'when using default configuration' do
    controller do
      def index
        render jsonapi: nil
      end
    end

    subject { JSON.parse(response.body) }

    it 'does not add links by default' do
      get :index

      expect(subject['links']).to be_nil
    end
  end

  context 'when using a custom configuration' do
    controller do
      def index
        render jsonapi: nil
      end
    end

    subject { JSON.parse(response.body) }

    it 'adds links by default' do
      with_config(jsonapi_links: ->() { { self: 'http://jsonapi-rb.org' } }) do
        get :index
      end

      expect(subject['links']).to eq('self' => 'http://jsonapi-rb.org')
    end
  end

  context 'when customizing jsonapi_links hook' do
    controller do
      def index
        render jsonapi: nil
      end

      def jsonapi_links
        { 'self' => 'http://jsonapi-rb.org' }
      end
    end

    subject { JSON.parse(response.body) }

    it 'adds serialized links by default' do
      get :index

      expect(subject['links']).to eq('self' => 'http://jsonapi-rb.org')
    end
  end

  context 'when providing links renderer option' do
    controller do
      def index
        render jsonapi: nil, links: { other: 'http://jsonapi-rb.org' }
      end

      def jsonapi_links
        {
          self: 'http://jsonapi-rb.org',
          other: 'http://other.org'
        }
      end
    end

    subject { JSON.parse(response.body) }

    it 'overrides top level links' do
      get :index

      expect(subject['links'])
        .to eq('self' => 'http://jsonapi-rb.org',
               'other' => 'http://jsonapi-rb.org')
    end
  end
end
