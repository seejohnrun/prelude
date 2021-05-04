module Prelude
  class Method
    def initialize(&blk)
      @definition = blk
    end

    def call(*args)
      @definition.call(*args)
    end
  end
end
