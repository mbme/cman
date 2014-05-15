require 'json'

# Here we have record wrapper.
module Cman
  def self.simplify_path(filepath)
    filepath.start_with?(Dir.home) ? filepath.sub!(Dir.home, '~') : filepath
  end

  # item record
  class Record
    def self.long_repo_file(rec)
      "#{rec.name} #{rec.id}"
    end

    attr_accessor :id, :path, :owner, :repository, :name

    def initialize(path, id: -1, repository: nil, name: '')
      @id = id
      @owner = ''
      @name = name
      @path = Cman.simplify_path path
      @repository = repository
    end

    def repo_file
      recs = @repository.records.select do |rec|
        rec != self && rec.name == @name
      end

      if recs.length > 0
        Record.long_repo_file self
      else
        @name
      end
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
        'owner' => @owner,
        'name' => @name
      )
    end

    def self.parse(hash)
      rec = Record.new hash['path'], id: hash['id']
      rec.name = hash['name']
      rec.owner = hash['owner']
      rec
    end
  end
end
