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
