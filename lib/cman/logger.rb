module Cman
  # Simple mixin logger
  module Logger
    LEVELS = { 0 => 'DEBUG', 1 => 'INFO ', 2 => 'WARN ', 3 => 'ERROR' }

    @@debug = true

    # get or set debug option
    def self.debug(enabled: nil)
      @@debug = enabled unless enabled.nil?
      @@debug
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
      exit 1
    end

    private

    def print(level, msg)
      level == 0 && !@@debug && return

      puts "#{LEVELS[level]}   #{msg}"
    end
  end
end
