require_relative '../lib/cman/record'
require_relative '../lib/cman/repository'
require_relative '../lib/cman/executor'

require 'yaml'
require 'pathname'
require 'fakefs/spec_helpers'
require 'singleton'

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

class DummyOutput
  include Singleton
  def write(*)
  end
end

RSpec.configure do |config|
  # original_stderr = $stderr
  original_stdout = $stdout

  config.before(:all) do
    # $stderr = nil
    $stdout = DummyOutput.instance
  end

  config.after(:all) do
    # $stderr = original_stderr
    $stdout = original_stdout
  end
end
