require "bundler/gem_tasks"
# task :default => [:test]

# task :test do
#   ruby "test/unittest.rb"
# end

task :run do
  ruby 'lib/cman.rb'
end
