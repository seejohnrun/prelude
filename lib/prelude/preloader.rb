module Prelude
  class Preloader
    def initialize(klass, records)
      @klass = klass
      @records_to_load = records
      @values = Hash.new { |h, k| h[k] = {} }
    end

    def fetch(name, object, *args)
      method = @klass.preloaders.fetch(name)

      # First check if this value already exists
      value = values_hash_for(method, args)[object]
      return value if value

      # Choose a batch of the correct size that contains the object we're trying to load,
      # or use all if we're not batching
      if method.batch_size
        slices = @records_to_load.each_slice(method.batch_size)
        slice = slices.detect { |slice| slice.include?(object) } || slices.first
        @records_to_load = @records_to_load.reject { |r| slice.include?(r) } # ensure we don't try to reload
        preload(method, slice, args)
      else
        preload(method, @records_to_load, args)
        @records_to_load = []
      end

      # Return the value for this object
      values_hash_for(method, args)[object]
    end

    private

    # Preload the given field with the given args for all records
    def preload(method, records, args)
      results = method.call(records, *args)

      if method.batch_size
        # In the case batch size is set, merge into a results array. Also
        # raise if default_proc is set on the Hash because we won't be able
        # to support that
        raise 'Cannot use default_proc with batch_size' if results.default_proc
        values_hash_for(method, args).merge!(results)
      else
        # In the case batch size isn't set, use the results hash directly
        # so that the user can use default_proc
        @values[method][args] = results
      end
    end

    def values_hash_for(method, args)
      @values[method][args] ||= {}
    end
  end
end
