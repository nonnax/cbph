#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-11-03 00:19:48 +0800
require 'excon'
require 'json'
require 'fileutils'
require 'rubytools/hash_ext'
require 'rubytools/thread_ext'
require 'rubytools/xxhsum'
require 'forwardable'
require 'csv'
require 'benchmark'
require 'monitor'

USERNAME=1

class CBUpdater
  extend Forwardable
  def_delegators :@df, :map, :each
  attr :picklist_ph, :picklist_beauty, :region_filter
  attr_accessor :df, :counter, :url

  def initialize(region: [])
    @df = []
    @url = ''
    @region_filter = region
    @counter=0
    @datastore = 'data.csv'
    @userstore = 'user.csv'
    @userhash={}
    reset_datastore()
    load_userstore()
  end

  def reset_datastore
    FileUtils.cp(@datastore, "#{Time.now.to_i}_#{@datastore}") if File.exists?(@datastore)
    File.write(@datastore, '')
  end

  def load_userstore
    Thread.new do
      CSV.foreach(@userstore) do |r|
        user, hash = r
        @userhash[user]=hash
      end
    end.join
  end
  def save_userstore()
      CSV.open(@userstore, 'w') do |csv|
        @userhash.each do |k, v|  
          csv<<[k,v]
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
      format: 'json',
    }
    unless region_filter.empty?
      params.merge!(region: region_filter) #if %w[asia europe_russia northamerica southamerica other].detect{|r| (/#{region_filter}/i).match(r)}
    end
    
    #"region 	asia | europe_russia | northamerica | southamerica | other region=asia&region=northamerica"
    self.url = ['https://chaturbate.com/api/public/affiliates/onlinerooms/', params.to_query_string(repeat_keys: true)].join('?')
    JSON.parse(Excon.get(url).body)
  end
  def update_counter
    @counter+=1
  end

  def populate_df(i)
    Monitor.new.synchronize do
      row = []
      data = get(i * 500)

      return [] if data['results'].empty?
      print [i, data['results'].size]
      # region 	asia | europe_russia | northamerica | southamerica | other
      keys = %w[image_url username location age current_show is_hd is_new num_users num_followers chat_room_url_revshare]
      data
        .to_h['results']
        .map do |r|
          # row << r.values_at(*keys) if r['age'] && r['age'] < 140
          row << r.values_at(*keys)
        end
      yield row.uniq.tap{|u| @df += u } #yield only new rows
      sleep 1
    end
  end

  def save_data_file(r)
      Monitor.new.synchronize do
        CSV.open(@datastore, 'a') do |csv|
          csv.flock(File::LOCK_EX) # Exclusive lock needed for writing
          r.dup.each do |e|
            i=update_counter
            unless @userhash[e[USERNAME]] 
              @userhash[e[USERNAME]] = e[USERNAME].xxhsum
            end
            userhash=@userhash[e[USERNAME]]
            csv << ([userhash]+e)
          end
          csv.flush
        end
      end
  end
end

region_filter=ARGV

t = []
worker = CBUpdater.new(region: region_filter)

info=Benchmark.measure do
  20.times do |i|    
      t<<Thread.new(i) do |i|
        worker.populate_df(i){ |r| worker.save_data_file(r) }
      end
  end
  t.map(&:join)
  Thread.new do
    worker.save_userstore()
  end.join
end

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
