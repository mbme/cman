require 'json'

# Here we have record wrapper.
module Cman
  BACKUP_EXT = '.cman'

  def self.simplify_path(filepath)
    filepath.start_with?(Dir.home) ? filepath.sub!(Dir.home, '~') : filepath
  end

  # item record
  class Record
    def self.repo_file(rec)
      rec.path.gsub '/', ':'
    end

    def self.parse(hash, repository)
      Record.new hash['path'], id: hash['id'], repository: repository
    end

    attr_accessor :id, :path, :repository

    def initialize(path, id: -1, repository: nil)
      @id = id
      @repository = repository
      @path = Cman.simplify_path path
    end

    def repo_file
      Record.repo_file self
    end

    def repo_path
      File.join @repository.path, repo_file
    end

    def backup_path
      name = File.basename(@path) + BACKUP_EXT

      name = name[0] == '.' ? name : '.' + name

      File.join File.dirname(@path), name
    end

    def install
      fail("#{@repository.name}: #{@path} already installed") if installed?

      # backup if exists
      if File.exist?(@path) || Dir.exist?(@path)
        FileUtils.mv @path, backup_path
      end

      FileUtils.ln_s repo_path, @path
    end

    def uninstall
      fail("#{@repository.name}: #{@path} not installed") unless installed?
      FileUtils.rm @path

      # restore backup if exists
      backup = backup_path
      FileUtils.mv backup, @path if File.exist?(backup) or Dir.exist?(backup)
    end

    def installed?
      File.symlink?(@path) && File.readlink(@path) == repo_path
    end

    def ==(other)
      @path == other.path
    end

    def to_json(*_)
      JSON.pretty_generate(
        'id' => @id,
        'path' => @path
      )
    end

    def to_s
      "#{@id}  #{@path}"
    end
  end
end
