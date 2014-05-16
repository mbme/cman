require 'json'

# Here we have record wrapper.
module Cman
  def self.simplify_path(filepath)
    filepath.start_with?(Dir.home) ? filepath.sub!(Dir.home, '~') : filepath
  end

  # item record
  class Record
    def self.repo_file(rec)
      rec.path.gsub '/', ':'
    end

    def self.parse(hash)
      Record.new hash['path'], id: hash['id'], owner: hash['owner']
    end

    attr_accessor :id, :path, :owner, :repository

    def initialize(path, id: -1, repository: nil, owner: '')
      @id = id
      @owner = owner
      @repository = repository
      @path = Cman.simplify_path path
    end

    def repo_file
      Record.repo_file self
    end

    def repo_path
      File.join @repository.path, repo_file
    end

    def ==(other)
      @path == other.path
    end

    def to_json(*_)
      JSON.pretty_generate(
        'id' => @id,
        'path' => @path,
        'owner' => @owner
      )
    end
  end
end
