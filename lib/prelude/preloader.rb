module Prelude
  class Preloader
    def initialize(klass, records)
      @klass = klass
      @records = records
      @runs = {}
    end

    def fetch(name, object, *args)
      method = @klass.prelude_methods.fetch(name)

      # If this object has a run, return the value
      if run = run_for(method, args)
        return run[object]
      end

      # Choose a run for the arguments that we're trying to load
      run = preload(method, @records, args)

      # Return the value for this object
      run[object]
    end

    private

    # Preload the given field with the given args for all records
    def preload(method, records, args)
      results = method.call(records, *args)

      # set the run for each of these name/record/args combos
      records.each do |record|
        set_run_for(method, args, results)
      end

      # Return the run
      results
    end

    def run_for(method, args)
      @runs.dig(method, args)
    end

    def set_run_for(method, args, run)
      @runs[method] ||= {}
      @runs[method][args] = run
    end
  end
end
