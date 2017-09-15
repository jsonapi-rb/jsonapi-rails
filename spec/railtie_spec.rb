require 'rails_helper'

describe JSONAPI::Rails::Railtie do
  it 'registers the JSON API MIME type' do
    expect(Mime[:jsonapi]).to eq('application/vnd.api+json')
  end

  it 'registers the params parser for the JSON API MIME type' do
    expect(::ActionDispatch::Request.parameter_parsers[:jsonapi]).not_to be_nil
  end

  it 'registers the FilterMediaType middleware' do
    expect(
      Rails.application.middleware.include?(JSONAPI::Rails::FilterMediaType)
    ).to be true
  end
end
