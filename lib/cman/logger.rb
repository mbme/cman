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
      log 0, msg
    end

    def info(msg)
      log 1, msg
    end

    def warn(msg)
      log 2, msg
    end

    def error(msg)
      log 3, msg
    end

    def dialog(msg)
      resp = ''
      until %w( y n ).include? resp
        info msg + ' (y/n)'
        resp = $stdin.gets.strip
      end

      resp == 'y'
    end

    private

    def log(level, msg)
      level == 0 && !@@debug && return

      puts "#{LEVELS[level]}   #{msg}"
    end
  end
end
