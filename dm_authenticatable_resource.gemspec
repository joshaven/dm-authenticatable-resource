$:.unshift('lib')
require 'dm_authenticatable_resource'
 
Gem::Specification.new do |s|
  s.author = "Joshaven Potter"
  s.email = 'yourtech@gmail.com'
  s.homepage = "http://github.com/joshaven"
 
  s.name = 'dm_authenticatable_resource'
  s.version = DataMapper::AuthenticatableResource::VERSION::STRING
  s.platform = Gem::Platform::RUBY
  s.summary = "Provides Authentication for models that use DataMapper"
  s.description = "This gem is framework independent.  It provides a simple way to make models authenticate users." +
    "Passwords can be encrypted with any of these types: MD5, SHA1, SHA2, AES-128, AES-192, AES-256"
  #s.rubyforge_project = "dm_authenticatable_resource"
 
  s.files = Dir['CHANGELOG', 'MIT-LICENSE', 'README', 'lib/**/*', 'spec/**/*']
  s.has_rdoc = true
  s.require_path = 'lib'
  s.requirements << 'none'
 
  s.add_dependency('rspec', '~> 1.2.9')
  s.add_dependency('dm-core', '~> 0.10.0')
end
