#!/usr/bin/env ruby
# Id$ nonnax 2022-02-03 19:15:45 +0800
require "down"
require "fileutils"

class Downloader
  def self.download(image_url, dest='.')
    tempfile = Down.download(image_url)
    FileUtils.mkdir(dest) unless Dir.exist?(dest)
    FileUtils.mv(tempfile.path, "#{dest}/#{tempfile.original_filename}")
  end
end
