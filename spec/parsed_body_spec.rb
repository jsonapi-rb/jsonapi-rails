require 'rails_helper'

describe ActionController::Base, type: :controller do
  controller do
    def index
      render jsonapi: nil
    end
  end

  subject(:parsed_body) { response.parsed_body }

  it 'allows using parsed_body in ActionController::TestCase' do
    get :index

    expect(parsed_body).to eq(JSON.parse(response.body))
  end
end
