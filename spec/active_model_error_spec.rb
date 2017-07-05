require 'spec_helper'

describe JSONAPI::Rails::ActiveModelError do
  class Thing
    include ActiveModel::Model
    attr_accessor :name, :description
    validates :name, presence: true
    validates :description, presence: true
  end

  let(:reverse_mapping) { { name: 'data/attributes/name', description: 'data/attributes/description' } }

  context 'building from a model' do
    it 'converts the model errors' do
      invalid_thing = Thing.new
      expect(invalid_thing.valid?).to be false

      errors = JSONAPI::Rails::ActiveModelError.from_errors(invalid_thing.errors, reverse_mapping)
      errors.sort_by! { |e| e.send(:title) }

      expect(errors.size).to eq 2
      expect(errors[0].send(:title)).to eq 'Invalid description'
      expect(errors[0].send(:detail)).to eq "Description can't be blank"
    end
  end
end
