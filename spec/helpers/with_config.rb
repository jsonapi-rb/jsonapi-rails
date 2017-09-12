module WithConfig
  def with_config(hash)
    JSONAPI::Rails.configure do |config|
      config.merge!(hash)
    end
    yield
    JSONAPI::Rails.configure do |config|
      config.clear
    end
  end
end
