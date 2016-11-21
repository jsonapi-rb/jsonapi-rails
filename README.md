# jsonapi-rails
Rails integration for [jsonapi-rb](https://github.com/jsonapi-rb/jsonapi-rb).

## Status

[![Gem Version](https://badge.fury.io/rb/jsonapi-rails.svg)](https://badge.fury.io/rb/jsonapi-rails)
[![Build Status](https://secure.travis-ci.org/jsonapi-rb/rails.svg?branch=master)](http://travis-ci.org/jsonapi-rb/rails?branch=master)
[![Gitter chat](https://badges.gitter.im/gitterHQ/gitter.png)](https://gitter.im/jsonapi-rb/Lobby)

## Installation

Add the following to your application's Gemfile:
```ruby
gem 'jsonapi-rails'
```
And then execute:
```
$ bundle
```

## Usage

### Serialization

Example:
```ruby
# app/serializable/serializable_user.rb
class SerializableUser < JSONAPI::Serializable::Resource
  type 'users'

  attribute :name
  attribute :email do
    "#{@object.name}@foo.bar"
  end

  has_many :posts do
    link(:related) { @url_helpers.user_posts(@object) }
    meta foo: :bar
  end

  has_many :comments do
    resources do
      @object.comments.order(:desc)
    end
  end

  has_many :reviews, Foo::Bar::SerializableRev

  link(:self) { @url_helpers.user_url(@object.id) }
  meta do
    { foo: 'bar' }
  end
end

# app/controllers/users_controller.rb
# ...
user = User.find_by(id: id)
render jsonapi: user, include: { posts: [:comments] }, meta: { foo: 'bar' }
# ...
```

### Deserialization

Example:
```ruby
class PostsController < ActionController::Base
  deserializable_resource :post, only: [:create, :update] do
    attribute :title
    attribute :date
    has_one :author do |rel, id, type|
      field user_id: id
      field user_type: type
    end
    has_many :comments
  end

  def create_params
    params.require(:user).permit!
  end

  def create
    create_params[:title]
    create_params[:date]
    create_params[:comment_ids]
    create_params[:comment_types]
    create_params[:user_id]
    create_params[:user_type]
    # ...
  end
end


```

## License

jsonapi-rails is released under the [MIT License](http://www.opensource.org/licenses/MIT).
