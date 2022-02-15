#!/usr/bin/env ruby
# Id$ nonnax 2022-02-03 13:30:01 +0800
require 'csv'
require './downloader'
require 'rubytools/console_ext'
require 'rubytools/thread_ext'

NAME_COL=2
URL_COL=1
URL='https://roomimg.stream.highwebmedia.com/ri/'

data=CSV.parse(File.read('data.csv'))
picks=CSV.parse(File.read('picklist')).flatten
 
def get_data(data, picks)
  # Monitor.new.synchronize do
    data
    .select{|e| picks.include?e[NAME_COL] }
    .map{|e| e[URL_COL]}
  # end
end

def download(data, picks)
  t=[]
    online=get_data(data, picks)
    online
      .each_with_index do |e, i| 
        t<<Thread.new(e, i)  do |e, i |
            # Downloader.download(e, 'live')
            # print "%<size>d%%\r" % {size: (i/online.size.to_f)*100}
            title = "% <i>s of %{size}" % {i:, size: online.size}
            puts title.rjust(10)
            sleep 0.5
          end
    end
  t.map(&:join)
end

# download(data, picks)

get_data(data, picks).each do |l|
  puts l
end
