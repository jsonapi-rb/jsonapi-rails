version = File.read(File.expand_path('../VERSION', __FILE__)).strip

Gem::Specification.new do |spec|
  spec.name          = 'jsonapi-rails'
  spec.version       = version
  spec.author        = ['L. Preston Sego III', 'Lucas Hosseini']
  spec.email         = ['LPSego3+dev@gmail.com', 'lucas.hosseini@gmail.com']
  spec.summary       = 'Rails plugin for (de)serialization of JSONAPI resources'
  spec.description   = 'Efficiently build and consume JSONAPI documents.'
  spec.homepage      = 'https://github.com/jsonapi-rb/rails'
  spec.license       = 'MIT'

  spec.files         = Dir['README.md', 'lib/**/*']
  spec.require_path  = 'lib'

  spec.add_dependency 'jsonapi-renderer', '0.1.1.beta2'
  spec.add_dependency 'jsonapi-parser', '0.1.1.beta3'
  spec.add_dependency 'jsonapi-serializable', '0.1.1.beta2'
  spec.add_dependency 'jsonapi-deserializable', '0.1.1.beta3'

  spec.add_development_dependency 'activerecord', '>=5'
  spec.add_development_dependency 'sqlite3', '>= 1.3.12'
  spec.add_development_dependency 'rake', '>=0.9'
  spec.add_development_dependency 'rspec', '~>3.4'
end
