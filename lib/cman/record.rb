require 'json'

# Here we have record wrapper.
module Cman
  def self.simplify_path(filepath)
    filepath.start_with?(Dir.home) ? filepath.sub!(Dir.home, '~') : filepath
  end

  # item record
  class Record
    attr_accessor :id, :path, :owner, :repository, :name

    def initialize(path, id: -1, repository: nil)
      @id = id
      @owner = ''
      @name = ''
      @path = Cman.simplify_path path
      @repository = repository
    end

    def repo_path
      File.join @repository.path, @name
    end

    def ==(other)
      @path == other.path
    end

    def to_json(*_)
      JSON.pretty_generate('id' => @id, 'path' => @path, 'owner' => @owner)
    end
  end
end
