module Prelude
  class Preloader
    def initialize(klass, records)
      @klass = klass
      @records = records
    end

    def fetch(name, *args)
      method = @klass.prelude_methods.fetch(name)

      # Only fetch for the objects needing values
      records_to_load = @records.reject { |r| r.has_preloaded_value_for?(name, args) }

      # Load and set the results for each record
      results = preload(records_to_load, method, args)
      records_to_load.each do |record|
        record.set_preloaded_value_for(name, args, results[record])
      end

      results
    end

    private

    # Preload the given field with the given args for all records
    def preload(records, method, args)
      method.call(records, *args)
    end
  end
end
