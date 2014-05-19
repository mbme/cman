require 'json'
require 'fileutils'
require 'cman/record'
require 'cman/utils'

# Here we have repository wrapper.
module Cman
  @@config = { 'base_dir' => '/home/test/repository' }

  def self.config
    @@config
  end

  # files repository
  class Repository
    REPO_CONFIG = '.cman'
    include Utils

    def self.read(name)
      repo = Repository.new name
      fail("#{name}: does not exist") unless repo.exist?
      repo.parse_json
    end

    def self.stats(name: nil)
      if name
        repo = Repository.read name
        info "#{name} stats:"
        info "records: #{repo.size}"
        repo.records.each do |rec|
          info "  #{rec.id} #{rec.path}"
        end
      else
        info 'stats:'
        info "home dir: #{@@config['base_dir']}"
      end
    end

    def self.save_after(*methods)
      methods.each do |method|
        mod = Module.new do
          define_method(method) do |*args, &block|
            result = super(*args, &block)
            save
            result
          end
        end
        prepend mod
      end
    end

    attr_reader :records, :name
    save_after :create, :add_record, :remove_record

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

    def exist?
      File.directory?(path)
    end

    def create
      fail("#{@name}: can't create repository: already exists") if exist?

      FileUtils.mkdir path
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
      fail("#{@name}: can't remove repository: doesn't exists") unless exist?
      FileUtils.rm_r path
    end

    def add_record(filepath)
      fail("#{filepath} doesn't exist") unless File.exist?(filepath)

      fail("#{filepath} is symlink") if File.symlink? filepath

      unless File.file?(filepath) or File.directory?(filepath)
        fail("#{filepath} is not file or dir")
      end

      rec = Record.new(filepath, id: free_id, repository: self)

      fail("#{@name}: already contains #{filepath}") if @records.include?(rec)

      copy_file filepath, rec.repo_path
      @records << rec

      rec
    end

    def remove_record(id)
      rec = get_record id, failIfNil: true

      @records.delete rec
      FileUtils.rm_r rec.repo_path
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

    def free_id
      rec = @records.max_by(&:id)

      rec.nil? ? 0 : rec.id + 1
    end

    def parse(hash)
      @name = hash['name']
      @records = hash['records'].map { |item| Record.parse item }
      self
    end
  end
end
