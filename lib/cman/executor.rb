require 'cman/logger'

module Cman
  # command executor exception
  class ExecutorError < StandardError
  end

  # command executor
  class Executor
    include Logger

    COMMANDS = %w(add remove install uninstall status)

    def initialize(command)
      unless COMMANDS.include? command
        fail("wrong command #{command}, valid are #{COMMANDS.join ', '}")
      end
      @command = command
    end

    def execute(*args)
      send @command, *args
    rescue ArgumentError => e
      raise ExecutorError, "command #{@command}; #{e.message}"
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
      info "status #{repo}"
    end
  end
end
