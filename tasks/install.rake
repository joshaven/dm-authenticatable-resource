desc "Install the created gem."
task :install => :gem do
  system("gem install pkg/#{gem_spec.name}-#{gem_spec.version}.gem")
end
