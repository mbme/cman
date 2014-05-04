#!/usr/bin/env ruby

require 'cman/logger'
log = MB::Logger.new 'main'

if __FILE__ != $PROGRAM_NAME
  log.fatal 'must be run as a program'
  return 1
end

log.info 'TEST!'
