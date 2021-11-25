#!/usr/bin/env ruby
# Id$ nonnax 2021-11-03 00:19:48 +0800
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
require 'excon'
require 'json'
require "down"
require "fileutils"
require 'rubytools/array_table'
require 'rubytools/hash_ext'
require 'rubytools/thread_ext'
require 'rubytools/fzf'
require 'forwardable'
require 'csv'
require 'celluloid'
require 'celluloid/pool'
require 'benchmark'

Celluloid.boot

class CBUpdater
  extend Forwardable
  include Celluloid
  def_delegators :@df, :map, :each
  attr :picklist_ph, :picklist_beauty
  attr_accessor :df, :th
  def initialize
    @df=[]
    @th=[]
    @data_file='data.txt'
    File.write(@data_file, '')
    pickfile='picklist_ph'
    pickfile_beauty='picklist_beauty'
    default_list=%w[murbears_world marymoody cielo69_ candy_temptation_]
    @picklist_ph=File.exists?(pickfile) ? File.read(pickfile).split("\n").uniq.map(&:strip) : default_list
    @picklist_beauty=File.exists?(pickfile_beauty) ? File.read(pickfile_beauty).split("\n").uniq.map(&:strip) : default_list
  end
  
  def download(image_url)
    tmp = Down.download(image_url, max_size: 24*1024) #24kb
    FileUtils.mv(tmp.path, "./media/#{tmp.original_filename}")
  end
  def get(offset, display_count=500)
    params={
      wm: 'LVTEy',
      client_ip: 'request_ip',
      limit: display_count,
      offset: offset,
      gender: 'f',
      format: 'json'
    }
    url="https://chaturbate.com/api/public/affiliates/onlinerooms/?#{params.to_query_string}"
    response = Excon.get(url)
    JSON.parse(response.body)
  end

  def populate_df(i)
      row = []  
      data=get(i*500)
      
      return if data['results'].empty?
      p [i, data['results'].size]
      
      keys=%w[image_url username location age current_show is_hd is_new num_followers iframe_embed]
      data
        .to_h
        .dig('results')
        .map do |r|
          row << r.values_at(*keys) if (/hilipp/i).match(r.fetch('location',''))
          row << r.values_at(*keys) if r['is_new']
          row << r.values_at(*keys) if (picklist_ph).include?(r.fetch('username'))
          row << r.values_at(*keys) if (r['age'] && r['age'] < 20 )
        end

      @df += row.uniq
      download_media_files( row )
      # sleep 2
  end
  
  def download_media_files(row)
    row.each do |r|
        download(r.dup.first) 
    end
  end
  def save_data_file
    CSV.open('data.csv', 'w') do |csv|
      @df.dup.map.with_index do |e, i|
        csv << e.values_at(0, 1, 2, 3, -1)
      end
    end
  end
end


worker=CBUpdater.pool(size: 10)
puts Benchmark.measure {
  11.times do | i |
      worker.async.populate_df(i)
  end
  worker.save_data_file
}
