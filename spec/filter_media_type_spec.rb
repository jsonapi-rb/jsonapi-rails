require 'rails_helper'

describe JSONAPI::Rails::FilterMediaType do
  let(:app) { ->(_) { [200, {}, ['OK']] } }

  context 'when not receiving JSON API Content-Type' do
    it 'passes through' do
      env = { 'CONTENT_TYPE' => 'application/json' }

      expect(described_class.new(app).call(env)[0]).to eq(200)
    end
  end

  context 'when receiving JSON API Content-Type without media parameters' do
    it 'passes through' do
      env = { 'CONTENT_TYPE' => 'application/vnd.api+json' }

      expect(described_class.new(app).call(env)[0]).to eq(200)
    end
  end

  context 'when receiving Content-Type with media parameters' do
    it 'fails with 415 Unsupported Media Type' do
      env = { 'CONTENT_TYPE' => 'application/vnd.api+json; charset=utf-8' }

      expect(described_class.new(app).call(env)[0]).to eq(415)
    end
  end

  context 'when not receiving JSON API in Accept' do
    it 'passes through' do
      env = { 'HTTP_ACCEPT' => 'application/json' }

      expect(described_class.new(app).call(env)[0]).to eq(200)
    end
  end

  context 'when receiving JSON API in Accept without media parameters' do
    it 'passes through' do
      env = { 'HTTP_ACCEPT' => 'application/vnd.api+json' }

      expect(described_class.new(app).call(env)[0]).to eq(200)
    end
  end

  context 'when receiving JSON API in Accept without media parameters among others' do
    it 'passes through' do
      env = { 'HTTP_ACCEPT' => 'application/json, application/vnd.api+json' }

      expect(described_class.new(app).call(env)[0]).to eq(200)
    end
  end

  context 'when receiving JSON API in Accept with media parameters' do
    it 'fails with 406 Not Acceptable' do
      env = { 'HTTP_ACCEPT' => 'application/vnd.api+json; charset=utf-8' }

      expect(described_class.new(app).call(env)[0]).to eq(406)
    end
  end

  context 'when receiving JSON API in Accept with media parameters among others' do
    it 'fails with 406 Not Acceptable' do
      env = { 'HTTP_ACCEPT' => 'application/json, application/vnd.api+json; charset=utf-8' }

      expect(described_class.new(app).call(env)[0]).to eq(406)
    end
  end
end
