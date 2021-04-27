module Prelude
  module Enumerator
    TypeMismatch = Class.new(StandardError)

    def with_prelude
      return to_enum(:with_prelude) unless block_given?

      raise TypeMismatch unless map(&:class).uniq.count == 1

      # Share a preloader
      Prelude.wrap(self)

      # Iterate
      each { |o| yield o }
    end
  end
end
