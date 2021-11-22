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
require 'rubytools/array_table'
require 'rubytools/fzf'

display_count=500
offset=ARGV.first || 0


picklist=File.exists?('picklist') ? File.read('picklist').split("\n").uniq.map(&:strip) : %w[murbears_world marymoody cielo69_ candy_temptation_]
picklist=File.exists?('picklist_beauty') ? File.read('picklist_beauty').split("\n").uniq.map(&:strip) : %w[murbears_world marymoody cielo69_ candy_temptation_]
# picklist= %w[murbears_world marymoody cielo69_ candy_temptation_ _stella_rose_]

def get(offset, display_count=500)
url="https://chaturbate.com/api/public/affiliates/onlinerooms/?wm=LVTEy&client_ip=request_ip&limit=#{display_count}&offset=#{offset}&gender=f&format=json"
  response = Excon.get(
    url
    # headers: {
    # cache-control: 'max-age=30,public,must-revalidate,s-maxage=1800',
    # content-type: 'application/json; charset=utf-8',
    # format: 'json',
    # gender: %w[f],
    # region: 'asia'
    # }
  )
  JSON.parse(response.body)
end

df=[]
location=Hash.new(0)
names=[]
5.times do | i |
   data=get(i*500)
  # puts JSON.pretty_generate(data)
    # puts JSON.pretty_generate(data
    # .to_h
    # .dig('results')
    # # .dig('results', 'current_show', 'is_hd', 'is_new','location', 'username', 'display_name', 'age' , 'num_followers')
    # )
  keys=%w[image_url username location age current_show is_hd is_new num_followers]
  data
    .to_h
    .dig('results')
    .map{|r|
      # # df << r.values_at('image_url_360x270', 'current_show', 'is_hd', 'is_new','location', 'username', 'age' , 'num_followers') if /^1/.match(r.values_at('age').first&.to_s)
      location[r.values_at('location').first]+=1
      df << r.values_at(*keys) if (/philip/i).match(r.values_at('location').first)
      df << r.values_at(*keys) if picklist.include?(r.values_at('username').first) #and !(/ppine/i).match(r.values_at('location').first&.to_s)
      df << r.values_at(*keys) if picklist_beauty.include?(r.values_at('username').first) #and !(/ppine/i).match(r.values_at('location').first&.to_s)
      df << r.values_at(*keys) if r.values_at('is_new').first
      # names << r.values_at('username').first
    }
  sleep 1
end

# p names.sort
# 
# # puts df.to_table(delim: ' ') unless df.empty?
# require "down"
# require "fileutils"
# 
# def download(image_url)
  # tempfile = Down.download(image_url)
  # FileUtils.mv(tempfile.path, "./#{tempfile.original_filename}")
# end

df.uniq.map.with_index{|e, i|
  # print "%02f%%\r" % [(i/df.size.to_f)*100]
  # p e.values_at(0, 1, 2, 3)
  puts e.values_at(0, 1, 2, 3).join('\\')
  # download(url)
}#.fzf_preview("mpv {+1}")

# puts df.to_table

# puts location.sort_by{|k, v| v}.reverse.to_h
IO.write('location.json', JSON.pretty_generate(location.sort_by{|k, v| v}.reverse.to_h))
