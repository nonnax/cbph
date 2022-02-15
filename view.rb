#!/usr/bin/env ruby
# Id$ nonnax 2022-02-14 14:38:48 +0800
require './userdb'
require 'rubytools/array_table'

loc, _ = ARGV
db=UserDB.new('userdata.db')

t=[]
online=[]

db
  .online
  .select{ |e| 
      e.location.match(/#{loc}/i)
  }
  .map{ |e|
    t<<Thread.new(e) do |e|
      e=>{username:, location:, image_url: , **reject}
      online<<[image_url, username,  location]
    end
  }

t.map(&:join)

online.each{ |e| 
  puts e.join("\t") 
}
