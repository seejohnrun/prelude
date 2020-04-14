module Prelude
  module Enumerator
    def with_prelude
      return to_enum(:with_prelude) unless block_given?

      # TODO check that all entries in this Array are of the same type

      # Share a preloader
      preloader = Preloader.new(first.class, self)
      each { |r| r.prelude_preloader = preloader }

      # Iterate
      each { |o| yield o }
    end
  end
end
