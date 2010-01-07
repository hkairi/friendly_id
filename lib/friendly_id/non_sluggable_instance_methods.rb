module FriendlyId::NonSluggableInstanceMethods

  def self.included(base)
    base.validate :validate_friendly_id
    base.class_eval do
      after_save :update_association_slugs
    end
  end

  attr :found_using_friendly_id

  # Was the record found using one of its friendly ids?
  def found_using_friendly_id?
    @found_using_friendly_id
  end

  # Was the record found using its numeric id?
  def found_using_numeric_id?
    !@found_using_friendly_id
  end
  alias has_better_id? found_using_numeric_id?

  # Returns the friendly_id.
  def friendly_id
    send friendly_id_options[:method]
  end
  alias best_id friendly_id

  # Returns the friendly id, or if none is available, the numeric id.
  def to_param
    (friendly_id || id).to_s
  end

  private

  def validate_friendly_id
    if self.class.friendly_id_options[:reserved].include? friendly_id
      self.errors.add(self.class.friendly_id_options[:method],
        self.class.friendly_id_options[:reserved_message] % friendly_id)
      return false
    end
  end

  def found_using_friendly_id=(value) #:nodoc#
    @found_using_friendly_id = value
  end
  
  def update_association_slugs
    self.class.reflect_on_all_associations.each do |assoc| 
      case assoc.macro
        when :has_many, :has_and_belongs_to_many then send(assoc.name).each { |related_object| update_slugs related_object }
        when :has_one then update_slugs send(assoc.name)
      end
    end
  end
  
  def update_slugs related_object
    if related_object.class.friendly_id_options[:use_slug]
      friendly_id_was = self.send(self.class.friendly_id_options[:method].to_s + '_was')
      Slug.find_all_by_sluggable_type_and_scope(related_object.class.name, friendly_id_was).each {|slug| slug.scope = self.friendly_id; slug.save }
    end
  end

end
