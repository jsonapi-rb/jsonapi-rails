require 'rails_helper'

RSpec.describe 'Basic CRUD', type: :request do
  let(:headers) do
    { 'ACCEPT' => 'application/vnd.api+json' }
  end

  def body
    JSON.parse(response.body)
  end

  it 'works' do
    # Get empty tweets list
    get '/tweets', headers: headers
    expect(response).to be_success
    expect(response).to have_http_status(200)
    expect(response.body).to be_valid_jsonapi
    expect(response.body).to match_schema do
      required(:data).value(eql?: [])
      required(:meta).value(eql?: { 'foo' => 'bar' })
      required(:jsonapi).value(eql?: { 'version' => '1.0' })
      required(:links).value(eql?: { 'self' => 'http://foo.bar' })
    end

    # Post first tweet
    params = {
      data: {
        type: 'tweets',
        attributes: {
          content: 'foo'
        },
        relationships: {
          author: {
            data: {
              id: 'foo',
              type: 'bar'
            }
          }
        }
      }
    }
    post '/tweets',
         params: params,
         as: :json,
         headers: headers.merge('CONTENT_TYPE' => 'application/vnd.api+json')
    expect(response).to be_success
    expect(response).to have_http_status(201)
    expect(response.body).to be_valid_jsonapi
    expect(response.body).to match_schema do
      required(:data).schema do
        required(:type).value(eql?: 'tweets')
        required(:attributes).schema do
          required(:content).value(eql?: 'foo')
        end
        required(:relationships).schema do
          required(:author)
        end
      end
    end
    first_tweet = body

    # Post second tweet
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

    # Get first tweet
    get "/tweets/#{first_tweet['data']['id']}", headers: headers
    expect(response).to be_success
    expect(response).to have_http_status(200)
    expect(response.body).to be_valid_jsonapi
    expect(body).to eq(first_tweet)

    # Delete first tweet
    delete "/tweets/#{first_tweet['data']['id']}"
    expect(response).to be_success
    expect(response).to have_http_status(204)

    # List remaining tweets
    get '/tweets'
    expect(response).to be_success
    expect(response).to have_http_status(200)
    expect(response.body).to be_valid_jsonapi
    expect(body['data'].first).to eq(second_tweet['data'])
  end
end
