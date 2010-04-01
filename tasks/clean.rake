desc "Delete generated files"
task :clean => [:clobber_package, :'doc:clean', :'website:clean']