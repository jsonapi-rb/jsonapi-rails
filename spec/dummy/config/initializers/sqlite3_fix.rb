if Rails.application.config.active_record.sqlite3.present?
  Rails.application.config.active_record.sqlite3.represent_boolean_as_integer = true
end
