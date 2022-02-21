#!/usr/bin/env ruby
# Id$ nonnax 2022-02-20 23:22:33 +0800
require 'gdbm'
require 'json'
require 'csv'
require 'rubytools/array_ext'
require 'rubytools/array_table'

# startpage=ARGV.shift

class String
  def to_h
    JSON.parse(self, symbolize_names: true)
  end
end

class Array
  def pager(at: 1, max_items: 50)
    n = [at.to_i-1, 0].max
    start=(n*max_items)
    p range=(n*max_items)...(start+max_items)
    self[range]
  end
end

def keys(f='uonline.csv')
  keys_passed = File.readlines(f, chomp: true)
end

def dbase(&)
  GDBM.open("userdata.db", &)
end

def values(&block)
  dbase do |db|
    db
    .keys
    .intersection(keys)
    .map{|k| db[k].to_h }
    .map
  end
end

def page(n, maxitems: 20)
  n &&= n-1
  n = [n, 0].max
  start=(n*maxitems)
  p range=(n*maxitems)...(start+maxitems)
  values.to_a[range]
end

def grep(q, location: nil)
  dbase do |db|
    db
    .select{|k, v| v.match(q) }
    .select{|k, v| 
        location ? v.to_h[:location].match(/#{location}/i) : true
      }
    # .select{|k, v|
        # v.to_h[:username].match(q)
      # }
  end
end

require 'optparse'

opts={}
OptionParser.new do |o|
  o.on '-q', '--query[?]'
  o.on '-w', '--where[?]'
  o.on '-l', '--live'
  o.on '-p', '--page[PAGE]', Integer
  o.on '-c', '--chunk[CHUNK]', Integer
end.parse!(into: opts)

# p page(startpage.to_i, maxitems: 50)&.size
start_page=opts[:page]
maxitems=opts[:chunk] || 50

# exit
# 
# if start_page
  # page(start_page, maxitems:).map do |v|
    # v=> {username:, location:, image_url:, **reject}
    # p [username:, location:]
  # end
# end
q=opts[:query]
w=opts[:where]
if q
  sel, rej = grep(/#{q}/i, location: w).partition{|k, v| keys.include?(k) } #.map{|k, v| k}
  # p 'select'
  puts sel.map{|k, v| k}.each_slice(4).to_a.pad_rows.to_table unless sel.empty?
  # p 'reject'
  # puts rej.map{|k, v| k}.each_slice(4).to_a.pad_rows.to_table unless rej.empty?
  
  t=[]
  found=[]
  grep(/#{q.strip}/i, location: w).map do |k, v|
          next unless keys.any?(k) if opts[:live]
          t<<Thread.new do
            v &&=v.to_h
            v => {username:, location:, image_url:, **reject}
            found<<{username:, location:, image_url:}
          end
  end
  t.map(&:join)

  p found.compact!
  
  puts found: found.size
  found.pager(at: start_page.to_i, max_items: 50)&.each_with_index do |e, i|
    p e
  end

end

puts opts.to_a.map{|e| e.join(":")}.join(", ")


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
