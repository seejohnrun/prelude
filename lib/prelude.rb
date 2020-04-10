require_relative 'prelude/version'
require_relative 'prelude/preloadable'
require_relative 'prelude/relation'

# Patch into AR::Relation to assign ourself to individual records where appropriate
ActiveRecord::Relation.prepend(Prelude::Relation)
