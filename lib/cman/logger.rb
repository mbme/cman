# Simple logger
module Cman
  # logger instance
  class Logger
    @@level = 1
    @@level_str = { 0 => 'DEBUG', 1 => 'INFO ', 2 => 'WARN ', 3 => 'ERROR' }

    def initialize(name)
      @name = name
    end

    def print(level, msg)
      level < @@level && return

      puts "#{@@level_str[level]}   #{msg}"
    end

    def debug(msg)
      print 0, msg
    end

    def info(msg)
      print 1, msg
    end

    def warn(msg)
      print 2, msg
    end

    def error(msg)
      print 3, msg
    end

    # setting or getting logger level
    def self.level(level: -1)
      level != -1 && @@level = level
      @@level
    end

    private :print
  end
end
