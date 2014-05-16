require 'cman/logger'

# main commands
module Cman
  # command executor
  class Executor
    include Logger

    @@commands = %w(add, remove, nstall, uninstall, status)

    def initialize(command)
      unless @@commands.include? command
        fail "wrong command #{command}, valid are #{@@commands.join ', '}"
      end
    end

    def execute(*args)
    end

    private

    def add(repo, *args)
      info 'adding'
    end

    def remove(repo, *args)
      info 'removing'
    end

    def install(repo, *args)
      info 'installing'
    end

    def uninstall(repo, *args)
      info 'uninstalling'
    end

    def status(repo = nil)
      info 'status'
    end
  end
end
