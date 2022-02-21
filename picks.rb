#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-02-03 13:30:01 +0800
require 'csv'
require './downloader'
require 'benchmark'
# require 'rubytools/console_ext'
require 'rubytools/thread_ext'
require './userdb'
require 'optparse'

save, = ARGV

opts={}
OptionParser.new do |o|
  o.on '-s', '--save'
  o.on '-p', '--page=[PAGE]'
  o.on '-r', '--reload'
end.parse!(into: opts)

p opts
# 
def get_data(message: :live_picks)
  db = UserDB.new
  db.send(*message).map do |k|
    p k unless db[k]
    db[k].values_at(:image_url, :username) if db[k]
  end.compact
end
# 
cmd={message: :live_picks}
cmd={message: [:page, opts[:page].to_i]} if opts[:page]
IO.popen('./uget.rb', &:read) if opts[:reload]

bm=Benchmark.measure do 
  t=[]
  get_data(**cmd).each do |e|
    t<<Thread.new(e) do |e|
      puts e.join("\t")
      Downloader.download(e.first, 'live') if opts[:save]  
      sleep 0.5
    end
  end
  p t.map(&:join).size
end

puts bm
