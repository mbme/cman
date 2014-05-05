require 'cman/logger'

# main commands
module Cman
  @log = Cman::Logger.new 'cman'

  def self.add(repo, *args)
    @log.info 'adding'
  end

  def self.remove(repo, *args)
    @log.info 'removing'
  end

  def self.install(repo, *args)
    @log.info 'installing'
  end

  def self.uninstall(repo, *args)
    @log.info 'uninstalling'
  end

  def self.status(repo = nil)
    @log.info 'status'
  end
end
