require 'rails_helper'

RSpec.describe JSONAPI::Rails::ActionController do
  class TestController < ActionController::Base
    deserializable_resource "things"
  end

  let(:controller) { TestController.new }

  context 'source pointers' do
    it 'should fetch the mapping created during deserialization' do
      reverse_mapping = {id: "/data/id", type: "/data/type"}
      allow(controller).to receive(:request) do
        OpenStruct.new(env: {'jsonapi_deserializable.reverse_mapping' => reverse_mapping})
      end
      expect(controller.send(:jsonapi_pointers)).to equal reverse_mapping
    end
  end
end
