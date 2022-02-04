require_relative './preloader'
require_relative './method'

module Prelude
  module Preloadable
    extend ActiveSupport::Concern

    attr_writer :prelude_preloader

    def preloaded_values
      @preloaded_values ||= {}
    end

    def set_preloaded_value_for(name, args, result)
      key = [name, args]
      preloaded_values[key] = result
    end

    class_methods do
      # Mapping of field name to block for resolving a given preloader
      def prelude_methods
        @prelude_methods ||= {}
      end

      # Copy parent prelude methods to subclasses
      def inherited(subclass)
        subclass.prelude_methods.merge!(prelude_methods)
        super
      end

      # Define how to preload a given method
      def define_prelude(name, &blk)
        prelude_methods[name] = Prelude::Method.new(&blk)

        define_method(name) do |*args|
          key = [name, args]
          return preloaded_values[key] if preloaded_values.key?(key)

          unless @prelude_preloader
            @prelude_preloader = Preloader.new([self])
          end

          @prelude_preloader.fetch(name, *args)
          preloaded_values[key]
        end
      end
    end
  end
end
