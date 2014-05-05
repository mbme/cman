module Cman
  @@config = {'base_dir' => '/home/test/repository'}

  def self.config
    @@config
  end

  class Record
    attr_accessor :id, :path, :owner
  end

  # files repository
  class Repository
    def initialize(name)
      @name = name
      @records = []
    end

    def path
      File.join Cman.config['base_dir'], @name
    end

    def exists?
      File.directory?(path)
    end
  end
end
