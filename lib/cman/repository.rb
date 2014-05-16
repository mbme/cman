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

    attr_reader :records

    def self.read(name)
      Repository.new(name).parse_json
    end

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

      FileUtils.mkdir path

      # create empty config file
      save
    end

    def size
      @records.length
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
      rec = Record.new(filepath, id: free_id, repository: self)

      @records.include?(rec) &&
        fail("repository #{@name} already contains #{filepath}")

      copy_file filepath, rec.repo_path
      @records << rec

      save
      rec
    end

    def remove_record(id)
      rec = get_record id, failIfNil: true

      @records.delete rec
      FileUtils.rm_rf rec.repo_path
    end

    def get_record(id, failIfNil: false)
      rec = @records.find { |r| r.id == id }
      if failIfNil && rec.nil?
        fail("#{@name}: can't find record with id #{id}")
      end

      rec
    end

    def to_json
      JSON.pretty_generate('name' => @name, 'records' => @records)
    end

    def parse_json
      parse JSON.parse File.read(config_path)
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

        relpath = Pathname.new(file).relative_path_from(src_path)
        file_dst =  dst_path.join(relpath).to_path

        FileUtils.mkdir_p File.dirname(file_dst)
        FileUtils.cp file, file_dst
      end
    end

    def free_id
      rec = @records.max_by(&:id)

      if rec
        rec.id + 1
      else
        0
      end
    end

    def parse(hash)
      @name = hash['name']
      @records = hash['records'].map { |item| Record.parse item }
      self
    end
  end
end
