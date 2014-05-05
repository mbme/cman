require "bundler/gem_tasks"
# task :default => [:test]

# task :test do
#   ruby "test/unittest.rb"
# end

task :run do
  ruby 'bin/cman status'
end

require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

# Default directory to look in is `/specs`
# Run with `rake spec`
RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = ['--color', '--format', 'nested']
end

task :default => :spec
