module Prelude
  class Preloader
    def initialize(klass, records)
      @klass = klass
      @records_to_load = records
      @batch_sizes = {}
      @values = Hash.new { |h, k| h[k] = {} }
    end

    def set_batch_size(name, batch_size)
      @batch_sizes[name] = batch_size
    end

    def fetch(name, object, *args)
      # First check if this value already exists
      value = values_hash_for(name, args)[object]
      return value if value

      batch_size = batch_size_for(name)

      # Choose a batch of the correct size that contains the object we're trying to load,
      # or use all if we're not batching
      if batch_size
        slices = @records_to_load.each_slice(batch_size)
        slice = slices.detect { |slice| slice.include?(object) } || slices.first
        @records_to_load = @records_to_load.reject { |r| slice.include?(r) } # ensure we don't try to reload
        preload(name, slice, args, batch_size: batch_size)
      else
        preload(name, @records_to_load, args)
        @records_to_load = []
      end

      # Return the value for this object
      values_hash_for(name, args)[object]
    end

    private

    # Preload the given field with the given args for all records
    def preload(name, records, args, batch_size: nil)
      results = @klass.preloaders[name].call(records, *args)

      if batch_size
        # In the case batch size is set, merge into a results array. Also
        # raise if default_proc is set on the Hash because we won't be able
        # to support that
        raise 'Cannot use default_proc with batch_size' if results.default_proc
        values_hash_for(name, args).merge!(results)
      else
        # In the case batch size isn't set, use the results hash directly
        # so that the user can use default_proc
        @values[name][args] = results
      end
    end

    def batch_size_for(name)
      @batch_sizes[name]
    end

    def values_hash_for(name, args)
      @values[name][args] ||= {}
    end
  end
end
