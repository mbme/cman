require 'fileutils'
require 'pathname'

module Cman
  # some common utils
  module Utils
    def copy_file(src, dst)
      if File.file?(src)
        FileUtils.cp src, dst
      elsif File.directory?(src)
        copy_dir src, dst
      end
    end

    def copy_dir(src, dst)
      dst_path = Pathname.new dst
      src_path = Pathname.new src

      Dir.glob("#{src}/**/*") do |file|
        next unless File.file? file

        relpath = Pathname.new(file).relative_path_from(src_path)
        file_dst =  dst_path.join(relpath).to_path

        FileUtils.mkdir_p File.dirname(file_dst)
        FileUtils.cp file, file_dst
      end
    end

    def mkdir(dir)
      FileUtils.mkdir dir
    end

    def rm(path)
      FileUtils.rm_r path
    end
  end
end