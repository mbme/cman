require 'json'
require 'fileutils'
require 'cman/record'
require 'pathname'

# Here we have repository wrapper.
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

    def delete
      exists? || fail("can't remove repository #{@name}: doesn't exists")
      FileUtils.rm_r path
    end

    def add_record(filepath)
      rec = Cman::Record.new(filepath, id: free_id, repository: self)

      @records.include?(rec) &&
        fail("repository #{@name} already contains #{filepath}")

      rec.name = File.basename filepath

      copy_file filepath, rec.repo_path

      @records << rec
      rec
    end

    def to_json
      JSON.pretty_generate('name' => @name, 'records' => @records)
    end

    private

    def copy_file(src, dst)
      if File.file?(src)
        FileUtils.cp src, dst
      elsif File.directory?(src)
        copy_dir src, dst
      end
    end

    def copy_dir(src, dst)
      dst_path = Pathname.new dst
      src_path = Pathname.new src

      Dir.glob("#{src}/**/*") do |file|
        next unless File.file? file

        file_dst =  dst_path.join(
          Pathname.new(file).relative_path_from(src_path)
        ).to_path

        puts file_dst
        FileUtils.mkdir_p File.dirname(file_dst)
        FileUtils.cp file, file_dst
      end
    end

    def free_id
      (@records.max_by(&:id) || -1) + 1
    end
  end
end
