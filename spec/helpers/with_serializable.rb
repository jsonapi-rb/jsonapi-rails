module WithSerializable
  def with_serializable(name, options = {}, &block)
    klass = Class.new(JSONAPI::Serializable::Resource, &block)
    before(*options[:scope]) do
      Object.const_set(name, klass)
    end
    after(*options[:scope]) do
      Object.send :remove_const, name
    end
  end
end
