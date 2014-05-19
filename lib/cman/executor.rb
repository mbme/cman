require 'pathname'
require 'cman/logger'
require 'cman/repository'
require 'cman/utils'

module Cman
  # command executor exception
  class ExecutorError < StandardError
  end

  # command executor
  class Executor
    include Logger
    include Utils

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

    def add(repo_name, *args)
      if args.length > 0
        add_files repo_name, args
      else
        add_repo repo_name
      end
    end

    def add_repo(repo_name)
      if dialog "#{repo_name}: add this repository?"
        repo = Cman::Repository.new repo_name

        fail ExecutorError, "#{repo_name} already exist" if repo.exist?

        repo.create
        info "#{repo_name}: created"
      else
        info 'cancelled'
      end
    end

    def add_files(repo_name, files)
      repo = Cman::Repository.read repo_name
      paths = *files.map { |f| build_path f }

      paths.each { |f| info f }
      if dialog "#{repo_name}: add this files?"
        paths.each { |f| add_file repo, f }
      else
        info 'cancelled'
      end
    end

    def add_file(repo, path)
      repo.add_record path

      info "added #{path}"
    rescue => e
      error "can't add #{path}: #{e.message}"
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
