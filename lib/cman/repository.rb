require 'json'
require 'fileutils'
require 'cman/record'
require 'cman/utils'

# Here we have repository wrapper.
module Cman
  CMAN_CONFIG_PATH = "#{Dir.home}/.config/cman"
  @@config = { 'base_dir' => nil }

  def self.config
    @@config
  end

  def self.load_config
    @@config = JSON.parse File.read(CMAN_CONFIG_PATH)
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

    def self.valid_name?(name)
      not name.start_with? '.'
    end

    attr_reader :records, :name
    save_after :create, :add_record, :remove_record

    def initialize(name)
      fail("#{name}: bad repository name") unless Repository.valid_name? name

      @name = name
      @records = []
    end

    def path
      File.join(Cman.config['base_dir'], @name)
    end

    def config_path
      File.join(path, REPO_CONFIG)
    end

    def exist?
      File.directory?(path) && File.exist?(config_path)
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

    def remove
      fail("#{@name}: can't remove repository: doesn't exists") unless exist?
      @records.each { |rec| remove_record rec.id }
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

      rec.uninstall if rec.installed?

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

    def stats
      fail("#{@name}: does not exist") unless exist?

      result = []

      result << "#{@name} stats:"
      result << "records: #{size}"

      records.each do |rec|
        result << "  #{rec.id} #{rec.path}"
      end

      result
    end

    private

    def free_id
      rec = @records.max_by(&:id)

      rec.nil? ? 0 : rec.id + 1
    end

    def parse(hash)
      @name = hash['name']
      @records = hash['records'].map { |item| Record.parse item, self }
      self
    end
  end
end
