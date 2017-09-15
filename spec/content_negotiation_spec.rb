require 'rails_helper'

describe ActionController::Base, type: :controller do
  controller do
    def index
      render jsonapi: nil
    end
  end

  context 'when sending data' do
    it 'responds with application/vnd.api+json' do
      get :index

      expect(response.headers['Content-Type']).to eq('application/vnd.api+json')
    end
  end
end
