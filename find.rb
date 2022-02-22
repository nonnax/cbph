#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-02-21 19:21:03 +0800
require 'gdbm'
require 'optparse'
require 'json'
require 'rubytools/array_table'
require 'rubytools/numeric_ext'

class String
  def as_hash
    JSON.parse(self, symbolize_names: true)
  end
end

class << self
  attr :db, :live_keys, :name, :where, :live, :pick_file
end

def live_db
  [live, pick_file].any? ? db.slice(*@live_keys) : db
end

def find(q, &)
  table =
    live_db
    .values
    .grep(q)  do |e|
      e.as_hash => { username:, location:, age:, num_followers:, image_url: }
      { username:, location: location[0..30], age:, num_followers:, image_url: }
    end
    .select{ |e| e[:location].match?(/#{where}/i)}
    .select{ |e| e[:username].match?(/#{name}/i)}
    .map(&:values)
    .sort_by { |h| h[-2] }
    # .reverse
  # table.each{|e| puts e.join("\t") }
  table.to_table(&) unless table.empty?
end

# begin

opts = {}

OptionParser.new do |o|
  o.on '-n', '--name=[STRING]'
  o.on '-w', '--where=[STRING]'
  o.on '-l', '--live'
  o.on '-p', '--pick=FILE'
end.parse!(into: opts)

@name = opts[:name]
@where = opts[:where]
@live = opts[:live]

@live_file = 'uonline.csv'
@db = GDBM.open('userdata.db', &:to_h)
@live_keys = File.readlines(@live_file, chomp: true)

@pick_file = opts[:pick]
if @pick_file
  picks = File.readlines(@pick_file, chomp: true)
  @live_keys = @live_keys.intersection(picks)
end


q, = ARGV
q = /#{q}/i
find(q) do |e|
    puts e.join("\t")
end

# https://chaturbate.com/api/public/affiliates/onlinerooms/?wm=LVTEy&client_ip=request_ip
# Supported parameters
# Param 	Choices 	Default 	Comments
# wm 	LVTEy 	– 	campaign slug (required)
# client_ip 	an ipv4 or ipv6 ip address or the string request_ip 	–
#
# The ip address used to filter rooms that have blocked users from a country or region (required)
#
# If you are making this request server side on behalf of a client, please use the ip address of the client request so that rooms are correctly filtered, e.g client_ip=230.32.32.6. If you are making this request from the client directly, you should set the parameter value to request_ip to indicate you want to use the requester's ip address, e.g client_ip=request_ip.
# format 	xml | json | yaml 	json 	The format the data will be returned as
# limit 	1-500 	100 	The max number of rooms to return in a single API call
# offset 	any non-negative integer 	0 	The number of results you wish to skip before selecting rooms
# exhibitionist 	true | false 	– 	–
# gender 	f | m | t | c 	– 	f = female, m = male, t = trans, c = couple
# You can filter by multiple genders by including multiple query parameters, e.g gender=f&gender=m
# region 	asia | europe_russia | northamerica | southamerica | other 	– 	You can filter by multiple regions by including multiple query parameters, e.g region=asia&region=northamerica
# tag 	– 	– 	You can filter by up to 5 tags by including multiple query parameters, e.g tag=feet&tag=bdsm
# hd 	true | false 	– 	–
# response:
# {
#   "count": 5428,
#   "results": [
#  {
# "username": "me_emily",
# "spoken_languages": "english",
# "tags": [
#   "squirt",
#   "lovense",
#   "anal",
#   "feet",
#   "daddy"
# ],
#   "current_show": "public",
#   "is_new": false,
#   "num_followers": 297766,
#   "birthday": "2002-11-25",
#   "is_hd": true,
#   "iframe_embed": "<iframe src='https://chaturbate.com/in/?tour=Jrvi&amp;campaign=LVTEy&amp;track=embed&amp;room=me_emily&amp;bgcolor=white' height=528 width=850 style='border: none;'></iframe>",
#   "seconds_online": 11712,
#   "display_name": "Emily",
#   "gender": "f",
#   "age": 19,
#   "image_url_360x270": "https://roomimg.stream.highwebmedia.com/ri/me_emily.jpg",
#   "num_users": 11958,
#   "chat_room_url": "https://chaturbate.com/in/?tour=yiMH&campaign=LVTEy&track=default&room=me_emily",
#   "image_url": "https://roomimg.stream.highwebmedia.com/ri/me_emily.jpg",
#   "location": "space",
#   "room_subject": "Goal: CUMSHOW & SQUIRT [764 tokens left] #squirt #lovense #anal #feet #daddy",
#   "chat_room_url_revshare": "https://chaturbate.com/in/?tour=LQps&campaign=LVTEy&track=default&room=me_emily",
#   "iframe_embed_revshare": "<iframe src='https://chaturbate.com/in/?tour=9oGW&amp;campaign=LVTEy&amp;track=embed&amp;room=me_emily&amp;bgcolor=white' height=528 width=850 style='border: none;'></iframe>"
#  },
# ],
# }
