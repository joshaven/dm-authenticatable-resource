$:.unshift('lib')
require 'dm-authenticatable-resource'
 
Gem::Specification.new do |s|
  s.author = "Joshaven Potter"
  s.email = 'yourtech@gmail.com'
  s.homepage = "http://github.com/joshaven"
 
  s.name = 'dm-authenticatable-resource'
  s.version = DataMapper::AuthenticatableResource::VERSION::STRING
  s.platform = Gem::Platform::RUBY
  s.summary = "Provides Authentication for models that use DataMapper"
  s.description = "This gem is framework independent.  It provides a simple way to make models authenticate users." +
    "Passwords can be encrypted with any of these types: MD5, SHA1, SHA2, AES-128, AES-192, AES-256"
  #s.rubyforge_project = "dm-authenticatable-resource"
 
  s.files = Dir['CHANGELOG.md', 'MIT-LICENSE.md', 'README.md', 'lib/**/*', 'spec/**/*']
  s.has_rdoc = true
  s.require_path = 'lib'
  s.requirements << 'none'
 
  # note: I have not tried with older versions of any of the dependencies below
  s.add_dependency 'dm-core',     '~> 0.10.2' 
  s.add_dependency 'rspec',       '~> 1.3.0'    # only needed for testing
  s.add_dependency 'do_sqlite3',  '~> 0.10.1.1' # only needed for testing
  s.add_dependency 'yard',        '~> 0.5.4'    # only for rdoc generation
end
