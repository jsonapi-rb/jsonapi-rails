require 'rails_helper'

RSpec.describe ActionController::Base do
  it 'exposes the deserialization mapping via the jsonapi_pointers method' do
    pointers = { id: '/data/id', type: '/data/type' }

    allow(subject).to receive(:request) do
      OpenStruct.new(
        env: {
          JSONAPI::Rails::ActionController::JSONAPI_POINTERS_KEY => pointers
        }
      )
    end

    expect(subject.send(:jsonapi_pointers)).to equal pointers
  end
end
