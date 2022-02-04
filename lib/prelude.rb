require_relative 'prelude/version'
require_relative 'prelude/preloadable'
require_relative 'prelude/enumerator'
require 'active_support'

module Prelude
  def self.wrap(records)
    preloader = Preloader.new(records)
    records.each { |r| r.prelude_preloader = preloader }
  end

  def self.preload(records, method, *args)
    wrap(records).each { |record| record.public_send(method, *args) }
  end
end

ActiveSupport.on_load :active_record do
  include Prelude::Preloadable
end

# Patch into Enumerator to support with_prelude
Enumerator.include(Prelude::Enumerator)
Enumerable.include(Prelude::Enumerator)
