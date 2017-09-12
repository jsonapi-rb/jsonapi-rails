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
end
