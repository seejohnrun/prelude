module Prelude
  class ValueNotPreloaded < StandardError; end

  class Preloaded < BasicObject
    def initialize(preloadable)
      @preloadable = preloadable
    end

    def method_missing(name, *args)
      if has_prelude_method?(name)
        fetch_preloaded_value(name, *args)
      else
        super
      end
    end

    def respond_to_missing?(name, include_private = false)
      has_prelude_method?(name) || super
    end

    private

    def has_prelude_method?(name)
      @preloadable.class.prelude_methods.has_key?(name)
    end

    def fetch_preloaded_value(name, *args)
      key = [name, args]
      @preloadable.preloaded_values.fetch(key)
    rescue ::KeyError
      ::Kernel.raise ::Prelude::ValueNotPreloaded,
        "#{@preloadable.inspect} has no preloaded value for method " +
        "##{name} with arguments #{args.inspect}"
    end
  end
end
