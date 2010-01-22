module FriendlyId::NonSluggableInstanceMethods

  def self.included(base)
    base.validate :validate_friendly_id
    base.after_save :update_scopes
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
  
  def friendly_id_changes
    changes[friendly_id_options[:method].to_s]
  end
  
  def update_scopes
    if changes = friendly_id_changes
      self.class.child_scopes.each do |klass|
        Slug.update_all "scope = '#{changes[1]}'", ["sluggable_type = ? AND scope = ?", klass.to_s, changes[0]]
      end
    end
  end

end