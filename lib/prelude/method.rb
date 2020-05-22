module Prelude
  class Method
    attr_reader :batch_size

    def initialize(batch_size:, &blk)
      @batch_size = batch_size
      @definition = blk
    end

    def call(*args)
      @definition.call(*args)
    end
  end
end
