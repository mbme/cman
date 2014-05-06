module Cman

  def self.simplify_path(filepath)
    filepath.start_with?(Dir.home) ? filepath.sub!(Dir.home, '~') : filepath
  end

  # item record
  class Record
    attr_accessor :id, :path, :owner, :repository

    def initialize(path)
      @id = -1
      @owner = ''
      @path = Cman.simplify_path path
      @repository = nil
    end

    def ==(other)
      @path == other.path
    end
  end
end
