require "friendly_id/common_instance_methods"

module FriendlyId::NonSluggableInstanceMethods
  include FriendlyId::CommonInstanceMethods

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
    update_associated_slugs(self.send(self.class.friendly_id_options[:method].to_s + '_was'))
  end

end
