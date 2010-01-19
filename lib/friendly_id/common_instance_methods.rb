module CommonInstanceMethods
  
  def update_associated_slugs friendly_id_was
    self.class.reflect_on_all_associations.each do |assoc| 
      case assoc.macro
        when :has_many, :has_and_belongs_to_many then send(assoc.name).each { |related_object| update_slugs related_object, friendly_id_was }
        when :has_one then update_slugs send(assoc.name), friendly_id_was
      end
    end
  end
  
  def update_slugs related_object, friendly_id_was
    if related_object.class.respond_to?('friendly_id_options') && related_object.class.friendly_id_options[:use_slug]
      Slug.find_all_by_sluggable_type_and_scope(related_object.class.name, friendly_id_was).each {|slug| slug.update_attribute :scope, self.friendly_id}
    end
  end
  
end
