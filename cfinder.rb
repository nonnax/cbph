#!/usr/bin/env ruby
# Id$ nonnax 2022-02-26 15:15:59 +0800
require './cbdb'
require 'optparse'

opts={}
OptionParser.new do |o|
  o.on '-l', '--location=LOCATION_REGEXP'
  o.on '-n', '--name=NAME_REGEXP'
  o.on '-a', '--age=AGE_REGEXP'
  o.on '-p', '--picks'
  o.on '-n', '--numpage=[PAGE]'
end.parse!(into: opts)

criteria={
  age: opts.fetch(:age, ''),
  location: opts.fetch(:location, ''),
  username: opts.fetch(:username, '')
}

DB.cb do |db|
  db.live_keys = db.live_keys & db.pick_keys if opts[:picks]
  live=db.each_slice
  # live=db.each_slice.to_a[opts[:numpage].to_i].map{|a| [a.last]}.map if opts[:numpage]
  found=[]
  loop do
    live
      .next
      .map{|k, _| db[k] if db.key?(k) }
      .map{|v| v[:age]=v[:age].to_i; v} # age: nil -> 0
      .grep_hash(**criteria){|e| e.all?}
      .each{|v|
        unless v.empty?
          v =>{ username:, location:, age:, image_url:}
          found << { username:, location: location[0..30], age: age.to_s, image_url:}
        end
      }
  end

  found.each{|e| puts e.values.join("\t")}
  p found.size
end
