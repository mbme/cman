require 'json'
require 'fileutils'

module Cman
  @@config = { 'base_dir' => '/home/test/repository' }

  def self.config
    @@config
  end

  # files repository
  class Repository
    REPO_CONFIG = '.cman'

    def initialize(name)
      @name = name
      @records = []
    end

    def path
      File.join Cman.config['base_dir'], @name
    end

    def config_path
      File.join(path, REPO_CONFIG)
    end

    def exists?
      File.directory?(path)
    end

    def create
      exists? && fail("can't create repository #{@name}: already exists")

      Dir.mkdir path

      # create empty config file
      save
    end

    def save
      File.open(config_path, 'w') do |file|
        file.puts to_json
      end
    end

    def remove
      exists? || fail("can't remove repository #{@name}: doesn't exists")
      FileUtils.rm_r path
    end

    def add(filepath)
    end

    def to_json
      JSON.pretty_generate('name' => @name, 'records' => @records)
    end
  end
end
