desc "Install the created gem."
task :install => :gem do
  gem_spec = eval(File.read('dm-authenticatable-resource.gemspec'))
  system("gem install pkg/#{gem_spec.name}-#{gem_spec.version}.gem")
end
