module Prelude
  class Preloader
    def initialize(records)
      @records = records
    end

    def fetch(name, *args)
      @records.group_by(&:class).flat_map do |klass, records|
        method = klass.prelude_methods.fetch(name)

        # Load and set the results for each record
        results = preload(method, args)
        records.each do |record|
          record.set_preloaded_value_for(name, args, results[record])
        end

        results
      end
    end

    private

    # Preload the given field with the given args for all records
    def preload(method, args)
      method.call(@records, *args)
    end
  end
end
