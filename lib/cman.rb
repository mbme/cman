require 'cman/logger'

# main commands
module Cman
  # command executor
  class Executor
    @@commands = %w(add, remove, nstall, uninstall, status)

    def initialize(command)
      @log = Logger.new 'executor'

      unless @@commands.include? command
        fail "wrong command #{command}, valid are #{@@commands.join ', '}"
      end
    end

    def execute(*args)
    end

    private

    def add(repo, *args)
      @log.info 'adding'
    end

    def remove(repo, *args)
      @log.info 'removing'
    end

    def install(repo, *args)
      @log.info 'installing'
    end

    def uninstall(repo, *args)
      @log.info 'uninstalling'
    end

    def status(repo = nil)
      @log.info 'status'
    end
  end
end
