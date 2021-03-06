require 'pathname'
require 'set'

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
        Cman::Repository.read(repo_name).remove

        info "#{repo_name}: removed"
      else
        info 'cancelled'
      end
    end

    def general_stats
      info 'stats:'
      base_dir = Cman.config['base_dir']
      info "home dir: #{base_dir}"

      repos = Dir.entries(base_dir).select do |f|
        next unless Cman::Repository.valid_name? f
        Cman::Repository.new(f).exist?
      end

      info "repositories: #{repos.length}"
      repos.each { |repo| info "#{repo}" }
    end

    def repo_stats(repo_name)
      repo = Repository.read repo_name
      repo.stats.each { |x| info x }
    rescue => e
      error e.message
    end

    def parse_int(id)
      Integer(id)
    rescue
      nil
    end

    def cleanup_ids(repo, ids)
      ids.map! { |i| parse_int i }.delete nil
      ids.each do |i|
        rec = repo.get_record(i)
        if rec.nil?
          ids.delete i
          error "#{repo.name}: can't find file with id #{i}"
        else
          info rec
        end
      end
    end

    def remove_file(repo, id)
      repo.remove_record id
      1
    rescue => e
      error "cannot remove #{id}: #{e.message}"
      0
    end

    def remove_files(repo_name, ids)
      repo = Cman::Repository.read repo_name
      cleanup_ids repo, ids

      if dialog "#{repo_name}: remove files?"
        total = 0
        ids.each { |i| total += remove_file repo, i }
        info "#{repo_name}: removed #{total} files"
      else
        info 'cancelled'
      end
    end

    def install_file(repo, id)
      repo.get_record(id).install
      1
    rescue => e
      error "cannot install #{id}: #{e.message}"
      0
    end

    def install_files(repo_name, ids)
      repo = Cman::Repository.read repo_name
      cleanup_ids repo, ids

      if dialog "#{repo_name}: install files?"
        total = 0
        ids.each { |i| total += install_file repo, i }
        info "#{repo_name}: installed #{total} files"
      else
        info 'cancelled'
      end
    end

    def install_repo(repo_name)
      repo = Cman::Repository.read repo_name
      ids = repo.records.map { |r| r.id }
      install_files repo_name, ids
    end

    def uninstall_files(repo_name, ids)
      repo = Cman::Repository.read repo_name
      cleanup_ids repo, ids

      if dialog "#{repo_name}: uninstall files?"
        ids.each { |i| repo.get_record(i).uninstall }
        info "#{repo_name}: uninstalled #{ids.length} files"
      else
        info 'cancelled'
      end
    end

    def uninstall_repo(repo_name)
      repo = Cman::Repository.read repo_name
      ids = repo.records.map { |r| r.id }
      uninstall_files repo_name, ids
    end
  end

  def uninstall_repo(repo_name)
    repo = Cman::Repository.read repo_name
    ids = repo.records.map { |r| r.id }
    uninstall_files repo_name, ids
  end

  # command executor
  class Executor
    include ExecutorUtils

    COMMANDS = %w(add remove install uninstall stats)

    def initialize(command)
      unless COMMANDS.include? command
        fail "wrong command '#{command}', valid are #{COMMANDS.join ', '}"
      end
      @command = command
    end

    def execute(opts)
      @opts = opts

      @repo_name = opts['<repository>']
      @ids = opts['<record_ids>'].to_set

      send @command
    rescue => e
      raise "command #{@command}: #{e.message}"
    end

    private

    def add
      files = @opts['<files>'].to_set
      if files.length > 0
        add_files @repo_name, files
      else
        add_repo @repo_name
      end
    end

    def remove
      if @ids.length > 0
        remove_files @repo_name, @ids
      else
        remove_repo @repo_name
      end
    end

    def install
      if @ids.length > 0
        install_files @repo_name, @ids
      else
        install_repo @repo_name
      end
    end

    def uninstall
      if @ids.length > 0
        uninstall_files @repo_name, @ids
      else
        uninstall_repo @repo_name
      end
    end

    def stats
      if @repo_name.nil?
        general_stats
      else
        repo_stats @repo_name
      end
    end
  end
end
