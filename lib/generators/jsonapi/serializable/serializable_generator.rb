module Jsonapi
  class SerializableGenerator < ::Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    # TODO(beauby): Implement generator-level whitelisting.
    # TODO(beauby): Implement versioning.

    def copy_serializable_file
      template 'serializable.rb.erb',
               File.join('app/serializable', class_path,
                         "serializable_#{file_name}.rb")
    end

    private

    def model_klass
      # TODO(beauby): Ensure the model class exists.
      class_name.safe_constantize
    end

    def type
      model_klass.name.underscore.pluralize
    end

    def attr_names
      attrs = model_klass.new.attribute_names - ['id']
      fk_attrs = model_klass.reflect_on_all_associations(:belongs_to)
                 .map(&:foreign_key)
      attrs - fk_attrs
    end

    def has_one_rel_names
      model_klass.reflect_on_all_associations(:has_one).map(&:name) +
        model_klass.reflect_on_all_associations(:belongs_to).map(&:name)
    end

    def has_many_rel_names
      model_klass.reflect_on_all_associations(:has_many).map(&:name)
    end
  end
end
