module Prelude
  module Relation
    def preload_associations(records)
      # Keep existing behavior
      super(records)

      # Add in our behavior
      if Preloadable === records.first
        preloader = Preloader.new(records.first.class, records)
        records.each { |r| r.prelude_preloader = preloader }
      end
    end
  end
end
