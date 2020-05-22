module Prelude
  class Preloader
    def initialize(klass, records)
      @klass = klass
      @records = records
      @values = Hash.new { |h, k| h[k] = {} }
    end

    # Preload the given field with the given args for all records
    def preload(name, *args)
      @values[name][args] ||= @klass.preloaders[name].call(@records, *args)
    end
  end
end
