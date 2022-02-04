#!/usr/bin/env ruby
# Id$ nonnax 2022-02-03 13:30:01 +0800
require 'csv'
require './downloader'
require 'rubytools/console_ext'

NAME_COL=2
URL_COL=1

data=CSV.parse(File.read('data.csv'))
picks=CSV.parse(File.read('picklist')).flatten

online=data
  .select{|e| picks.include?e[NAME_COL] }


IO::Screen.quiet_draw do
  online
    .map{|e| e[URL_COL]}
    .sort
    .each_with_index{|e, i| 
        Downloader.download(e, 'live')
        print "%<size>d%%\r" % {size: (i/online.size.to_f)*100}
      }
end
