require_relative 'prelude/version'
require_relative 'prelude/preloadable'
require_relative 'prelude/enumerator'
require 'active_support'

ActiveSupport.on_load :active_record do
  include Prelude::Preloadable
end

# Patch into Enumerator to support with_prelude
Enumerator.include(Prelude::Enumerator)
Enumerable.include(Prelude::Enumerator)
