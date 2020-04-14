lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'prelude/version'

Gem::Specification.new do |s|
  s.name = 'prelude'
  s.summary = 'ActiveRecord custom preloading'
  s.author = 'John Crepezzi'
  s.email = 'john.crepezzi@gmail.com'
  s.license = 'MIT'

  s.version = Prelude::VERSION
  s.platform = Gem::Platform::RUBY
  s.files = Dir['lib/**/*.rb']
  s.test_files = Dir.glob('spec/**/*.rb')
  s.require_paths = ['lib']

  s.add_dependency('activerecord')
  s.add_development_dependency('rspec')
  s.add_development_dependency('sqlite3')
  s.add_development_dependency('pry-byebug')
end
