require 'unzip/version'
require 'fileutils'
require 'kconv'

require 'rubygems'
require 'zipruby'

module Zip
  class Archive
    def encrypted?
      name = self.get_name(0)
      stat = self.get_stat(name)
      return stat.encryption_method != Zip::EM_NONE
    end
  end
end

module Unzip
  class CLI
    def self.extract_all(zip_filename, outdir = nil)
      outdir ||= File.dirname(zip_filename)
      Zip::Archive.open(zip_filename) do |ar|
        if ar.encrypted?
          print 'enter password: '
          $stdout.flush
          password = $stdin.gets.chomp
          ar.decrypt(password)
        end
        ar.each do |e|
          utf8_name = e.name.toutf8.gsub('\\', '/')
          utf8_path = File.join(outdir, utf8_name)
          if e.directory?
            FileUtils.mkdir_p(utf8_path)
          else
            dirname = File.dirname(utf8_path)
            FileUtils.mkdir_p(dirname) unless File.exist?(dirname)
            open(utf8_path, 'wb') { |f| f << e.read }
          end
        end
      end
    end
  end
end
