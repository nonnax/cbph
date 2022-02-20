#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-11-03 00:19:48 +0800
require 'excon'
require 'json'
require 'rubytools/hash_ext'
require 'rubytools/thread_ext'
require 'rubytools/string_ext'
require 'rubytools/file_ext'
require 'benchmark'
require 'monitor'
require 'csv'
require 'gdbm'

USERNAME = 1
REGIONS = %w[asia europe_russia northamerica southamerica other].freeze


class CBUpdater
  attr :picklist_ph, :picklist_beauty, :region_filter, 
       :exhibitionist_filter, :gender_filter, :config
       
  attr_accessor :df, :counter, :url

  def initialize(**h)
    regions = nil
    regions = REGIONS.select { |e| h[:region].any? { |f| e.match(f) } } if h[:region]
    @url = ''
    @region_filter = regions
    @exhibitionist_filter = h[:exhibitionist]
    @gender_filter = h[:gender]
    @userdata = {}
    @config = JSON.parse(File.read('cb.conf'), symbolize_names: true)
    @userdata_file = 'userdata.db'
    @userdata_online = 'uonline.csv'
  end

  def save_userdata
    p 'saving....'
    File.backup(@userdata_online)
    GDBM.open(@userdata_file) do |db|
      CSV.open(@userdata_online, 'w') do |csv|
        @userdata.each do |k, u|
          db[k] = u.to_json unless db.key?(k)
          csv<<[k]
        end
      end
    end
  end

  def get(offset, display_count = 500)
    params = {
      wm: 'LVTEy',
      client_ip: 'request_ip',
      limit: display_count,
      offset: offset,
      gender: 'f',
      format: 'json'
    }
    # if %w[asia europe_russia northamerica southamerica other].detect{|r| (/#{region_filter}/i).match(r)}
    # "region 	asia | europe_russia | northamerica | southamerica | other region=asia&region=northamerica"
    params.merge!(region: region_filter) unless region_filter.nil?
    params.merge!(gender: gender_filter) unless gender_filter.nil?
    params.merge!(exhibitionist: true) unless exhibitionist_filter.nil?

    self.url = [config[:url].decode64, params.to_query_string(repeat_keys: true)].join('?')
    JSON.parse(Excon.get(url).body)
  end

  def populate_df(i)
    Monitor.new.synchronize do
      row = []
      data = self.get(i * 500)

      return [] if data['results'].empty?
      p [i, data['results'].size]
      data['results']
        .map do |h|
          key=h['username']
          @userdata[key]=h
        end
      sleep 1
    end
  end
end

require 'optparse'

opts = {}

OptionParser.new do |o|
  o.on '-g', '--gender=[GENDER]', 'f m t c', Array
  o.on '-r', '--region=[REGION]', 'asia europe_russia northamerica southamerica other', Array
  o.on '-e', '--exhibitionist=[TRUE]', 'exhibitionist (TRUE/FALSE)'
end.parse!(into: opts)

worker = CBUpdater.new(**opts)

t = []
info = Benchmark.measure do
  15.times do |i|
    t << Thread.new(i){ |i| worker.populate_df(i) }
  end
  t.map( &:join )
end

worker.save_userdata

puts info
puts worker.url
puts "region filer:	#{$PROGRAM_NAME} asia europe_russia northamerica southamerica other"

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
# {
#   "username": "kikicola",
#   "spoken_languages": "English",
#   "tags": [
#     "18",
#     "asian",
#     "daddy",
#     "natural",
#     "teen"
#   ],
#   "current_show": "public",
#   "is_new": false,
#   "num_followers": 24355,
#   "birthday": "2003-06-13",
#   "is_hd": true,
#   "iframe_embed": "<iframe src='https://chaturbate.com/in/?tour=Jrvi&amp;campaign=LVTEy&amp;track=embed&amp;room=kikicola&amp;bgcolor=white' height=528 width=850 style='border: none;'></iframe>",
#   "seconds_online": 17143,
#   "display_name": "kikicola",
#   "gender": "f",
#   "age": 18,
#   "image_url_360x270": "https://roomimg.stream.highwebmedia.com/ri/kikicola.jpg",
#   "num_users": 12763,
#   "chat_room_url": "https://chaturbate.com/in/?tour=yiMH&campaign=LVTEy&track=default&room=kikicola",
#   "image_url": "https://roomimg.stream.highwebmedia.com/ri/kikicola.jpg",
#   "location": "Somewhere",
#   "room_subject": "im a little shy~ - Repeating Goal: striptease - #18 #asian #daddy #natural #teen",
#   "chat_room_url_revshare": "https://chaturbate.com/in/?tour=LQps&campaign=LVTEy&track=default&room=kikicola",
#   "iframe_embed_revshare": "<iframe src='https://chaturbate.com/in/?tour=9oGW&amp;campaign=LVTEy&amp;track=embed&amp;room=kikicola&amp;bgcolor=white' height=528 width=850 style='border: none;'></iframe>"
#  },
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
#  {
# "username": "urdreamolivia69",
# "spoken_languages": "English",
# "tags": [
#   "hairy",
#   "new",
#   "squirt",
#   "asian",
#   "mistress"
# ],
#   "current_show": "public",
#   "is_new": false,
#   "num_followers": 392,
#   "birthday": "",
#   "is_hd": false,
#   "iframe_embed": "<iframe src='https://chaturbate.com/in/?tour=Jrvi&amp;campaign=LVTEy&amp;track=embed&amp;room=urdreamolivia69&amp;bgcolor=white' height=528 width=850 style='border: none;'></iframe>",
#   "seconds_online": 197,
#   "display_name": "Maria",
#   "gender": "f",
#   "age": null,
#   "image_url_360x270": "https://roomimg.stream.highwebmedia.com/ri/urdreamolivia69.jpg",
#   "num_users": 1,
#   "chat_room_url": "https://chaturbate.com/in/?tour=yiMH&campaign=LVTEy&track=default&room=urdreamolivia69",
#   "image_url": "https://roomimg.stream.highwebmedia.com/ri/urdreamolivia69.jpg",
#   "location": "Bangkok Thailand",
#   "room_subject": "Fuck and cum on my wet creamy pussy  #hairy #squirt  #new #asian #mistress",
#   "chat_room_url_revshare": "https://chaturbate.com/in/?tour=LQps&campaign=LVTEy&track=default&room=urdreamolivia69",
#   "iframe_embed_revshare": "<iframe src='https://chaturbate.com/in/?tour=9oGW&amp;campaign=LVTEy&amp;track=embed&amp;room=urdreamolivia69&amp;bgcolor=white' height=528 width=850 style='border: none;'></iframe>"
#   },
#  ]
# }
