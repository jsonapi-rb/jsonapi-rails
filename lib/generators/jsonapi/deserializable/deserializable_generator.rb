module Jsonapi
  class DeserializableGenerator < ::Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    # TODO(beauby): Implement generator-level whitelisting.
    # TODO(beauby): Implement versioning.

    def copy_deserializable_file
      template 'deserializable.rb.erb',
               File.join('app/deserializable', class_path,
                         "deserializable_#{file_name}.rb")
    end

    private

    def model_klass
      # TODO(beauby): Ensure the model class exists.
      class_name.safe_constantize
    end

    def attr_names
      attrs = model_klass.new.attribute_names - %w(id created_at updated_at)
      fk_attrs = model_klass.reflect_on_all_associations(:belongs_to)
                            .map(&:foreign_key)
      attrs - fk_attrs
    end

    def has_one_rels
      has_one = model_klass.reflect_on_all_associations(:has_one)
      belongs_to = model_klass.reflect_on_all_associations(:belongs_to)

      has_one + belongs_to
    end

    def has_one_id_field_name(rel_name)
      "#{rel_name}_id"
    end

    def has_one_type_field_name(rel_name)
      "#{rel_name}_type"
    end

    def has_many_rels
      model_klass.reflect_on_all_associations(:has_many)
    end

    def has_many_id_field_name(rel_name)
      "#{rel_name.to_s.singularize}_ids"
    end

    def has_many_type_field_name(rel_name)
      "#{rel_name.to_s.singularize}_types"
    end
  end
end
