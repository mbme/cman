require_relative '../lib/cman/record'
require_relative '../lib/cman/repository'
require_relative '../lib/cman/executor'

require 'yaml'
require 'pathname'
require 'fakefs/spec_helpers'

def touch(*files)
  files.each do |file|
    FileUtils.mkdir_p File.dirname file
    File.open(file, 'w') { |f| f.write 'TEST' }
  end
end

def cat(file)
  puts "\n\n--- File #{file}:"
  File.readlines(file).each do |line|
    puts line
  end
  puts "\n\n--- #{file} ends here\n\n"
end

BASE_DIR = Cman.config['base_dir']
