require 'pathname'
require 'cman/logger'
require 'cman/repository'
require 'cman/utils'

module Cman
  # command executor exception
  class ExecutorError < StandardError
  end

  # helper methods for executor
  module ExecutorUtils
    include Logger
    include Utils

    private

    def add_repo(repo_name)
      if dialog "#{repo_name}: create repository?"
        Cman::Repository.new(repo_name).create

        info "#{repo_name}: created"
      else
        info 'cancelled'
      end
    end

    def add_files(repo_name, files)
      repo = Cman::Repository.read repo_name
      paths = files.map { |f| build_path f }

      paths.each { |f| info f }
      if dialog "#{repo_name}: add files?"
        count = paths.map { |f| add_file repo, f }.compact.length
        info "#{repo_name}: added #{count} files"
      else
        info 'cancelled'
      end
    end

    def add_file(repo, path)
      rec = repo.add_record path
      debug "added #{path}"
      rec
    rescue => e
      error "can't add #{path}: #{e.message}"
    end

    def remove_repo(repo_name)
      if dialog "#{repo_name}: remove repository?"
        Cman::Repository.read(repo_name).delete

        info "#{repo_name}: deleted"
      else
        info 'cancelled'
      end
    end

    def general_stats
      info 'stats:'
      info "home dir: #{Cman.config['base_dir']}"
    end

    def repo_stats(repo_name)
      repo = Repository.read repo_name
      repo.stats.each { |x| info x }
    rescue => e
      error e.message
    end

    def cleanup_ids(repo, ids)
      ids.each do |i|
        rec = repo.get_record(i)
        if rec.nil?
          ids.delete i
          error "#{repo_name}: can't find file with id #{i}"
        else
          info rec
        end
      end
    end

    def remove_files(repo_name, ids)
      repo = Cman::Repository.read repo_name
      cleanup_ids repo, ids

      if dialog "#{repo_name}: remove files?"
        ids.each { |i| repo.remove_record i }
        info "#{repo_name}: deleted #{ids.length} files"
      else
        info 'cancelled'
      end
    end
  end

  # command executor
  class Executor
    include ExecutorUtils

    COMMANDS = %w(add remove install uninstall stats)

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
        add_files repo_name, args.to_set
      else
        add_repo repo_name
      end
    end

    def remove(repo_name, *args)
      if args.length > 0
        remove_files repo_name, args.to_set
      else
        remove_repo repo_name
      end
    end

    def install(repo, *args)
      info 'installing'
    end

    def uninstall(repo, *args)
      info 'uninstalling'
    end

    def stats(repo_name = nil)
      if repo_name.nil?
        general_stats
      else
        repo_stats repo_name
      end
    end
  end
end
