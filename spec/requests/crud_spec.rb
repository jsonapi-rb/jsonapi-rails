require 'rails_helper'

RSpec.describe 'Basic CRUD', type: :request do
  let(:headers) do
    { 'ACCEPT' => 'application/vnd.api+json' }
  end

  def body
    JSON.parse(response.body)
  end

  it 'works' do
    get '/tweets', headers: headers
    expect(response).to be_success
    expect(response).to have_http_status(200)
    expected = {
      'data' => []
    }
    expect { JSONAPI.parse_response!(body) }.not_to raise_error
    expect(body).to eq(expected)

    params = {
      data: {
        type: 'tweets',
        attributes: {
          content: 'foo'
        }
      }
    }
    post '/tweets',
         params: params,
         as: :json,
         headers: headers.merge('CONTENT_TYPE' => 'application/vnd.api+json')
    expect(response).to be_success
    expect(response).to have_http_status(201)
    expect { JSONAPI.parse_response!(body) }.not_to raise_error
    first_tweet = body

    params = {
      data: {
        type: 'tweets',
        attributes: {
          content: 'foo'
        }
      }
    }
    post '/tweets',
         params: params,
         as: :json,
         headers: headers.merge('CONTENT_TYPE' => 'application/vnd.api+json')
    expect(response).to be_success
    expect(response).to have_http_status(201)
    expect { JSONAPI.parse_response!(body) }.not_to raise_error
    second_tweet = body

    get "/tweets/#{first_tweet['data']['id']}", headers: headers
    expect(response).to be_success
    expect(response).to have_http_status(200)
    expect { JSONAPI.parse_response!(body) }.not_to raise_error
    expect(body).to eq(first_tweet)

    delete "/tweets/#{first_tweet['data']['id']}"
    expect(response).to be_success
    expect(response).to have_http_status(204)

    get '/tweets'
    expect(response).to be_success
    expect(response).to have_http_status(200)
    expect { JSONAPI.parse_response!(body) }.not_to raise_error
    expect(body['data'].first).to eq(second_tweet['data'])
  end
end
