require_relative './preloader'

module Prelude
  module Preloadable
    extend ActiveSupport::Concern

    attr_writer :prelude_preloader

    class_methods do
      # Mapping of field name to block for resolving a given preloader
      def preloaders
        @prelude_preloaders ||= {}
      end

      # Define how to preload a given method
      def define_prelude(name, &blk)
        preloaders[name] = blk

        define_method(name) do
          unless @prelude_preloader
            @prelude_preloader = Preloader.new(self.class, [self])
          end

          @prelude_preloader.preload(name)
          @prelude_preloader.fetch(name, self)
        end
      end
    end
  end
end
