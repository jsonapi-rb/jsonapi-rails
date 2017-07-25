require 'rails_helper'

describe JSONAPI::Rails.config do
  context 'when the default configuration is used' do
    it 'should register the jsonapi parameter parser' do
      expect(JSONAPI::Rails.config.register_parameter_parser).to be true
    end

    it 'should register the jsonapi mime type' do
      expect(JSONAPI::Rails.config.register_mime_type).to be true
    end

    it 'should register the jsonapi renderers' do
      expect(JSONAPI::Rails.config.register_renderers).to be true
    end
  end

  context 'when a custom configuration is used' do
    before do
      JSONAPI::Rails.configure do |config|
        config.register_parameter_parser = false
        config.register_mime_type = false
        config.register_renderers = false
      end
    end

    it 'should not register the jsonapi parameter parser' do
      expect(JSONAPI::Rails.config.register_parameter_parser).to be false
    end

    it 'should not register the jsonapi mime type' do
      expect(JSONAPI::Rails.config.register_mime_type).to be false
    end

    it 'should not register the jsonapi renderers' do
      expect(JSONAPI::Rails.config.register_renderers).to be false
    end
  end
end
