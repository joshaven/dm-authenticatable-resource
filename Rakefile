# 
# rspec
require 'spec'
require 'spec/rake/spectask'
Spec::Rake::SpecTask.new do |task|
  task.libs << 'lib'
end
 
#
# Gem Packaging
require 'rake/gempackagetask'
gem_spec = eval(File.read('dm-authenticatable-resource.gemspec'))
Rake::GemPackageTask.new(gem_spec) do |p|
  p.gem_spec = gem_spec
  p.need_tar = true
  p.need_zip = true
end
 
#
# Gem Management
desc "Install the created gem."
task :install => :gem do
  system("gem install pkg/#{gem_spec.name}-#{gem_spec.version}.gem")
end
 
desc "Uninstall the gem."
task :uninstall do
  #
  # gem uninstall seems to only try the first path
  # to uninstall gems from.  On my system the gems
  # are located in ~/.gem which happens to be the
  # second path.  This bit of code tries
  # to remove the gem from ALL the gem paths.
  require 'yaml'
  gem_env = YAML::parse(`gem environment`)
  gem_env.select('/RubyGems Environment/*/GEM PATHS/*').each do |path|
    gems_path = path.value
    puts "Trying to remove gem from path: #{gems_path}"
    system("gem uninstall #{gem_spec.name} --version '=#{gem_spec.version}' --install-dir=#{gems_path}")
  end
end
 
desc "Delete generated files"
task :clean => :clobber_package do
    # all handled by dependencies for now. 
end
