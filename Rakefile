#
# Gem Packaging
require 'rake/gempackagetask'

gem_spec = eval(File.read('dm-authenticatable-resource.gemspec'))

Rake::GemPackageTask.new(gem_spec) do |p|
  p.gem_spec = gem_spec
  p.need_tar = true
  p.need_zip = true
end
 
GEMVERSION = DataMapper::AuthenticatableResource::VERSION::STRING

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }
