JSONAPI::Rails.configure do |config|
  # # Set a default serializable class mapper
  # # Can be a Proc or any object that responds to #call(class_name)
  # #  e.g. MyCustomMapper.call('User::Article') => User::SerializableArticle
  # config.jsonapi_class_mapper = -> (class_name) do
  #   names = class_name.to_s.split('::')
  #   klass = names.pop
  #   [*names, "Serializable#{klass}"].join('::').safe_constantize
  # end
  #
  # # Set any default serializable class mappings
  # config.jsonapi_class_mappings = {
  #   :Car => SerializableVehicle,
  #   :Boat => SerializableVehicle
  # }
  #
  # # Set a default serializable class mapper for errors.
  # # Can be a Proc or any object that responds to #call(class_name)
  # #  e.g. MyCustomMapper.call('PORO::Error') => PORO::SerializableError
  # # If no jsonapi_errors_class_mapper is configured jsonapi_class_mapper will
  # #  be used
  # config.jsonapi_errors_class_mapper = config.jsonapi_class_mapper.dup
  #
  # # Set any default serializable class errors mappings
  # config.jsonapi_errors_class_mappings = {
  #   :'MyCustomModule::ErrorObject' => MyCustomModule::SerializableErrorObject,
  #   :'ActiveModel::Errors' => JSONAPI::Rails::SerializableActiveModelErrors,
  #   :Hash => JSONAPI::Rails::SerializableErrorHash
  # }
  #
  # # Set a default JSON API object.
  # config.jsonapi_object = {
  #   version: '1.0'
  # }
  #
  # # Set default cache.
  # # A lambda/proc that will be eval'd in the controller context.
  # config.jsonapi_cache = ->() { nil }
  #
  # # Uncomment the following to enable fragment caching. Make sure you
  # #   invalidate cache keys accordingly.
  # config.jsonapi_cache = lambda {
  #   Rails.cache
  # }
  #
  # # Set default exposures.
  # # A lambda/proc that will be eval'd in the controller context.
  # config.jsonapi_expose = lambda {
  #   { url_helpers: ::Rails.application.routes.url_helpers }
  # }
  #
  # # Set default fields.
  # # A lambda/proc that will be eval'd in the controller context.
  # config.jsonapi_fields = ->() { nil }
  #
  # # Uncomment the following to have it default to the `fields` query
  # #   parameter.
  # config.jsonapi_fields = lambda {
  #   fields_param = params.to_unsafe_hash.fetch(:fields, {})
  #   Hash[fields_param.map { |k, v| [k.to_sym, v.split(',').map!(&:to_sym)] }]
  # }
  #
  # # Set default include.
  # # A lambda/proc that will be eval'd in the controller context.
  # config.jsonapi_include = ->() { nil }
  #
  # # Uncomment the following to have it default to the `include` query
  # #   parameter.
  # config.jsonapi_include = lambda {
  #   params[:include]
  # }
  #
  # # Set default links.
  # # A lambda/proc that will be eval'd in the controller context.
  # config.jsonapi_links = ->() { {} }
  #
  # # Set default meta.
  # # A lambda/proc that will be eval'd in the controller context.
  # config.jsonapi_meta = ->() { nil }
  #
  # # Set a default pagination scheme.
  # config.jsonapi_pagination = ->(_) { {} }
  #
  # # Set a logger.
  # config.logger = Logger.new(STDOUT)
  #
  # # Uncomment the following to disable logging.
  # config.logger = Logger.new('/dev/null')
end
