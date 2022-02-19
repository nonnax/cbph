#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-02-03 13:30:01 +0800
require 'csv'
require './downloader'
require 'benchmark'
# require 'rubytools/console_ext'
require 'rubytools/thread_ext'
require './userdb'

save, = ARGV

# data = CSV.read('usersonline.csv').flatten
# picks = CSV.read('userspicks.csv').flatten
# 
def get_data
  db = UserDB.new
  db.live_picks do |k|
    db[k].values_at(:image_url, :username)
  end
end

def download
  t = []
  online = get_data
  online.each_with_index do |e, i|
    t << Thread.new(e, i) do |e, i|
      p [i.succ, online.size].join('/')
      Downloader.download(e.first, 'live')
      sleep 2
    end
  end
  t.map(&:join)
end

bm=Benchmark.measure do 
  download if save

  get_data.each do |l|
    puts l.join("\t")
  end
end

puts bm
