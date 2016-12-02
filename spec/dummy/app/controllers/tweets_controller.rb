class TweetsController < ActionController::Base
  deserializable_resource :tweet, only: [:create, :update]

  def index
    tweets = Tweet.all

    render jsonapi: tweets
  end

  def show
    tweet = Tweet.find(params[:id])

    render jsonapi: tweet
  end

  def create
    tweet = Tweet.new(create_params.merge(author: current_user))

    unless tweet.save
      render jsonapi_errors: tweet.errors
      return
    end

    render jsonapi: tweet, status: :created
  end

  def destroy
    Tweet.delete(params[:id])

    head :no_content
  end

  private

  def current_user
    User.first || User.create(name: 'Lucas', email: 'lucas@jsonapi-rb.org')
  end

  def create_params
    params.require(:tweet).permit(:content, :parent_id)
  end
end
