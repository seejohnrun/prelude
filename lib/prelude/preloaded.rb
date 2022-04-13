module Prelude
  class ValueNotPreloaded < StandardError; end

  class Preloaded
    def initialize(preloadable)
      @preloadable = preloadable
    end

    def method_missing(name, *args)
      if respond_to_missing?(name, false)
        fetch(name, *args)
      else
        super
      end
    end

    def respond_to_missing?(name, include_private)
      @preloadable.class.prelude_methods.has_key?(name) || super
    end

    private

    def fetch(name, *args)
      key = [name, args]
      @preloadable.preloaded_values.fetch(key)
    rescue KeyError
      raise ValueNotPreloaded,
        "#{@preloadable.inspect} has no preloaded value for method " +
        "##{name} with arguments #{args.inspect}"
    end
  end
end
