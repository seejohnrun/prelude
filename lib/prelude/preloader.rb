module Prelude
  class Preloader
    def initialize(klass, records)
      @klass = klass
      @records = records
      @values = {}
    end

    # Preload the given field for all records
    def preload(name)
      @values[name] ||= @klass.preloaders[name].call(@records)
    end

    # Fetch the preloaded value for the given instance
    def fetch(name, object)
      @values.dig(name, object)
    end
  end
end
