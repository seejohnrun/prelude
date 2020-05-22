module Prelude
  class Preloader
    def initialize(klass, records)
      @klass = klass
      @records = records

      @resolvers = {}
    end

    def fetch(name, object, *args)
      method = @klass.preloaders.fetch(name)

      # If this object has a resolver, return the value
      if resolver = resolver_for(method, args, object)
        return resolver[object]
      end

      # Choose a batch of the correct size that contains the object we're trying to load,
      # or use all if we're not batching
      resolver = if method.batch_size
        remaining_records = @records.to_a - resolved_objects_for(method, args)
        slices = remaining_records.each_slice(method.batch_size)
        slice = slices.detect { |slice| slice.include?(object) }
        preload(method, slice, args)
      else
        preload(method, @records, args)
      end

      # Return the value for this object
      resolver[object]
    end

    private

    # Preload the given field with the given args for all records
    def preload(method, records, args)
      results = method.call(records, *args)

      # set the resolver for each of these name/record/args combos
      records.each do |record|
        set_resolver_for(method, args, record, results)
      end

      # Return the resolver
      results
    end

    def resolver_for(method, args, object)
      @resolvers.dig(method, args, object)
    end

    def resolved_objects_for(method, args)
      @resolvers.dig(method, args)&.keys || []
    end

    def set_resolver_for(method, args, object, resolver)
      @resolvers[method] ||= {}
      @resolvers[method][args] ||= {}
      @resolvers[method][args][object] = resolver
    end
  end
end
