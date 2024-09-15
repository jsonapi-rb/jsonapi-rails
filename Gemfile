source 'https://rubygems.org'

rails_version = ENV['RAILS_VERSION'] || "default"
require_sqlite3_1x = %w[7.0.0 6.1.0 6.0.0].include?(rails_version)

rails =
  case rails_version
  when 'main'
    { github: 'rails/rails' }
  when 'default'
    '>= 6.0'
  else
    "~> #{ENV['RAILS_VERSION']}"
  end

gem 'rails', rails
gem 'sqlite3', '~> 1.3' if require_sqlite3_1x

gemspec
