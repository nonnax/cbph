#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-11-03 00:19:48 +0800
require 'excon'
require 'json'
require 'fileutils'
require 'rubytools/hash_ext'
require 'rubytools/thread_ext'
require 'forwardable'
require 'csv'
require 'benchmark'

class CBUpdater
  extend Forwardable
  def_delegators :@df, :map, :each
  attr :picklist_ph, :picklist_beauty
  attr_accessor :df, :counter

  def initialize
    @df = []
    @counter=0
    @datastore = 'data.csv'
    reset_datastore()
  end

  def reset_datastore
    FileUtils.cp(@datastore, "#{Time.now.to_i}_#{@datastore}") if File.exists?(@datastore)
    File.write(@datastore, '')
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
    url = "https://chaturbate.com/api/public/affiliates/onlinerooms/?#{params.to_query_string}"
    response = Excon.get(url)
    JSON.parse(response.body)
  end
  def update_counter
    @counter+=1
  end

  def populate_df(i)
    row = []
    data = get(i * 500)

    return [] if data['results'].empty?
    p [i, data['results'].size]
    # region 	asia | europe_russia | northamerica | southamerica | other
    keys = %w[image_url username location age current_show is_hd is_new num_users num_followers chat_room_url_revshare]
    data
      .to_h['results']
      .map do |r|
        row << r.values_at(*keys) if r['age'] && r['age'] < 30
      end

    @df += row.uniq
    yield row.uniq
    sleep 1
  end

  def save_data_file(r)
    CSV.open(@datastore, 'a') do |csv|
      csv.flock(File::LOCK_EX) # Exclusive lock needed for writing
      r.dup.each do |e|
        i=update_counter
        csv << ([i]+e)
      end
      csv.flush
    end
  end
end

t = []
worker = CBUpdater.new
info=Benchmark.measure do
  12.times do |i|
    t<<Thread.new do 
      worker.populate_df(i){ |r| worker.save_data_file(r) }
    end
  end
  t.map(&:join)
end

puts info

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
# "username": "urdreamolivia69",
# "spoken_languages": "English",
# "tags": [
# "hairy",
# "new",
# "squirt",
# "asian",
# "mistress"
# ],
# "current_show": "public",
# "is_new": false,
# "num_followers": 392,
# "birthday": "",
# "is_hd": false,
# "iframe_embed": "<iframe src='https://chaturbate.com/in/?tour=Jrvi&amp;campaign=LVTEy&amp;track=embed&amp;room=urdreamolivia69&amp;bgcolor=white' height=528 width=850 style='border: none;'></iframe>",
# "seconds_online": 197,
# "display_name": "Maria",
# "gender": "f",
# "age": null,
# "image_url_360x270": "https://roomimg.stream.highwebmedia.com/ri/urdreamolivia69.jpg",
# "num_users": 1,
# "chat_room_url": "https://chaturbate.com/in/?tour=yiMH&campaign=LVTEy&track=default&room=urdreamolivia69",
# "image_url": "https://roomimg.stream.highwebmedia.com/ri/urdreamolivia69.jpg",
# "location": "Bangkok Thailand",
# "room_subject": "Fuck and cum on my wet creamy pussy  #hairy #squirt  #new #asian #mistress",
# "chat_room_url_revshare": "https://chaturbate.com/in/?tour=LQps&campaign=LVTEy&track=default&room=urdreamolivia69",
# "iframe_embed_revshare": "<iframe src='https://chaturbate.com/in/?tour=9oGW&amp;campaign=LVTEy&amp;track=embed&amp;room=urdreamolivia69&amp;bgcolor=white' height=528 width=850 style='border: none;'></iframe>"
# },
