#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-12-01 17:34:07 +0800
# require 'gdbm'
# require 'json'
# require 'rubytools/time_and_date_ext'
# require 'rubytools/numeric_ext'
# require 'csv'
# 
q = ARGV.first
# online = CSV.read('usersonline.csv').flatten
# GDBM.open('userdata.db') do |gdbm|
  # res = gdbm.values.grep(/#{q}/).sort
# 
  # res.each do |u|
    # user = JSON.parse(u, symbolize_names: true)
    # user => {username:, location:, num_followers:, seconds_online:, age:, image_url:, current_show:, **reject}
    # next unless online.include?(username)
# 
    # puts [image_url, username, age, location, (1000 * seconds_online).to_ts, current_show, num_followers].join("\t")
  # end
# 
  # all_found = res.map { |u| JSON.parse(u, symbolize_names: true)[:username] }
# 
  # on, off = all_found.partition { |f| online.include?(f) }
  # p [:on, on.size, on]
  # p [:off, off.size, off]
  # puts found: res.size
  # puts gdbm.size
# end

require './userdb'
require 'csv'
require 'json'

udb=UserDB.new('userdata.db')
i=0

if q
  rb=udb.grep(/#{q}/, online:true){ |r|
     r=>{username:, location:, image_url:, **reject}
     loc=(location.size>30 ? location[0..30]+'...' : location)
     puts [image_url, username, loc].join("\t")
  }
  p found: rb.compact.size
else
  # 
  udb.live_picks.each do |k|
    next if udb[k].nil?
    puts udb[k].values_at(:image_url, :username, :location).join("\t") 
  end
  p picks: udb.live_picks.size
end
