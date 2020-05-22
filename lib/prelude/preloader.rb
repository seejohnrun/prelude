module Prelude
  class Preloader
    def initialize(klass, records)
      @klass = klass
      @records = records

      @runs = {}
    end

    def fetch(name, object, *args)
      method = @klass.preloaders.fetch(name)

      # If this object has a run, return the value
      if run = run_for(method, args, object)
        return run[object]
      end

      # Choose a batch of the correct size that contains the object we're trying to load,
      # or use all if we're not batching
      run = if method.batch_size
        remaining_records = @records.to_a - resolved_objects_for(method, args)
        slices = remaining_records.each_slice(method.batch_size)
        slice = slices.detect { |slice| slice.include?(object) }
        preload(method, slice, args)
      else
        preload(method, @records, args)
      end

      # Return the value for this object
      run[object]
    end

    private

    # Preload the given field with the given args for all records
    def preload(method, records, args)
      results = method.call(records, *args)

      # set the run for each of these name/record/args combos
      records.each do |record|
        set_run_for(method, args, record, results)
      end

      # Return the run
      results
    end

    def run_for(method, args, object)
      @runs.dig(method, args, object)
    end

    def resolved_objects_for(method, args)
      @runs.dig(method, args)&.keys || []
    end

    def set_run_for(method, args, object, run)
      @runs[method] ||= {}
      @runs[method][args] ||= {}
      @runs[method][args][object] = run
    end
  end
end
