require_relative 'prelude/version'
require_relative 'prelude/preloadable'
require_relative 'prelude/relation'
require_relative 'prelude/enumerator'

# Patch into AR::Relation to assign ourself to individual records where appropriate
ActiveRecord::Relation.prepend(Prelude::Relation)

# Patch into Enumerator to support with_prelude
Enumerator.include(Prelude::Enumerator)
