module FriendlyId::CommonClassMethods

    def child_scopes
      @child_scopes ||= associated_friendly_classes.select do |klass|
        klass.friendly_id_options[:scope] == to_s.underscore.to_sym
      end
    end

    def associated_friendly_classes
      reflect_on_all_associations.select { |assoc| assoc.klass.respond_to? :friendly_id_options }.map(&:klass)
    end

end