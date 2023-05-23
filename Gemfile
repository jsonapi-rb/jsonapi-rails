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

gemspec
