source 'https://rubygems.org'

rails_version = ENV['RAILS_VERSION'] || "default"
rails =
  case rails_version
  when 'main'
    { github: 'rails/rails' }
  when 'default'
    '>= 5.0'
  else
    "~> #{ENV['RAILS_VERSION']}"
  end

gem 'rails', rails

# Required for Rails 6.1.x with Ruby 3.1+
if RUBY_VERSION >= '3.1'
  gem 'net-smtp', require: false
  gem 'net-imap', require: false
  gem 'net-pop', require: false
end


gemspec
