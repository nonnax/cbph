#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-11-04 21:05:10 +0800
require 'rubytools/cubadoo'
require 'csv'
require 'cgi'
keys=%i[rec_id image_url username location age current_show is_hd is_new num_users num_followers chat_room_url_revshare]
REC_ID, IMAGE_URL, USERNAME, LOCATION, AGE, CURRENT_SHOW, IS_HD, IS_NEW, NUM_USERS, NUM_FOLLOWERS, CHAT_ROOM_URL_REVSHARE = *(0..keys.size)
OFFSET=100
Cuba.class_eval do
  def _layout(&block)
    html_ do
      head_ do
        meta_('http-equiv': 'refresh', content: '120')
        # link(rel: 'stylesheet', type: "text/css",  href: '/css/style.css')
        link_(rel: 'stylesheet', type: 'text/css', href: '/css/style001.css')
      end
      body_ do        
        div_( id: 'banner') do
          div_( id: 'home' ){
            a_( href: '/'){h1_ { '..:: MetaCamVerse ::..' } }
            span_{'..:: veni vidi vici  ::..'}
          }          
          div_( id: 'search' ) do
            form_(action: '/search', method: 'get') do
              input_(type: 'text', name: 'q' )
              input_(type: 'submit', value: 'q')
            end
            div_(class: 'new') do
              ul_ do
                li_{a_(href: '/newbies/1/0'){ 'newbies' }}
                li_{a_(href: '/hd/1/0'){ 'HD' }}
              end
            end
          end
        end
        div_(id: 'content', &block)
      end
    end
  end

  def location_links(rooms)
    div_(class: 'location') do
      rooms.map { |r| r[LOCATION] }.uniq.map do |loc|
        a_(class: 'page', href: "/search/1/#{loc}") { loc }
      end
    end
  end

  def page_info(page, pages)
    div_ do
      "(#{page + 1} of #{pages})"
    end
  end

  def montage(vrooms, page, offset = OFFSET)
    rooms = vrooms.uniq.sort_by { |r| r[NUM_FOLLOWERS].to_i }.reverse
    div_ do
      t=[]
      rooms[page * offset..(page * offset + offset - 1)].map do |u|
        t<<Thread.new do
          rec_id, image_url, username, location, age, current_show, is_hd, is_new, num_users, num_followers, chat_room_url_revshare = u
            div_(class: 'grid') do
              div_(class: 'center') do
                a_(href: "/room/#{rec_id}", target: '_blank') do
                  img_(src: image_url)
                end
              end
              div_(class: 'user') do
                p_ { username }
                p_ { location }
                p_ { num_followers }
                p_ { is_new }
              end
            end
        end
        t.map(&:join)
      end
    end
  end

  def render_rooms(vrooms, pg = 1, q = '', offset = OFFSET)
    rooms = vrooms
    page = pg.to_i - 1    
    pages = (rooms.size / offset.to_f).floor
    links = location_links(rooms)
    montage_view = montage(rooms, page)
    req_base, req_page, req_q =env[Rack::REQUEST_PATH].scan(/\w+/)
    pagination=tagz do 
        pages.times do |i|
        page==i ? span_(class: 'current_page'){ "[#{i+1}]" } : a_(class: 'page', href: "/#{req_base}/#{i + 1}/#{q}") { b_ { (i + 1) } }
        end 
    end
    render(layout: true) do
      div_ do
        div_(class: 'pages') do
          if pages.zero?
            span_(class: 'page'){'1'}
          else
            pagination
            # pages.times do |i|
              # page==i ? span_(class: 'current_page'){ "[#{i+1}]" } : a_(class: 'page', href: "/#{req_base}/#{i + 1}/#{q}") { b_ { (i + 1) } }
            # end
          end
        end 
        p_ { montage_view }
        div_(class: 'clearfix') { hr_ }
        div_(class: 'pages') { pagination }
        p_ { links }
      end
    end
  end

  def datastore
    CSV.read('./data.csv')
  end
  
end

Cuba.define do
  rooms = datastore()

  on get do
    # /media/style.css
    on 'styler', extension('css') do |file|
      render(layout: true) { "Filename: #{file}" } #=> "Filename: style"
    end
    # /search?q=barbaz
    on 'search', param('q') do |q|
      res.redirect "/search/1/#{q}"
    end

    on 'rooms/:page' do |pg|
      page = pg.to_i - 1
      offset = OFFSET
      pages = (rooms.size / offset.to_f).floor
      montage_view = montage(rooms, page)
      render(layout: true) do
        div_ do
          div_(class: 'pages') do
            pages.times do |i|
              page==i ? span_(class: 'current_page'){ "[#{i+1}]" } : a_(class: 'page', href: "/rooms/#{i + 1}") { b_{ i + 1 } }
            end
          end
          p_ { montage_view }
        end
      end
    end

    on 'search/:page/:loc' do |page, loc|
      loc_decoded=Rack::Utils.unescape(loc)
      rooms = datastore()
      rooms = rooms.select { |r| (/#{loc_decoded}/i).match(r[LOCATION]) }
      render_rooms(rooms, page, loc)
    end

    on 'room/:id' do |id|
      rooms = datastore()
      room = rooms.detect{ |r| r.first==id }
      res.redirect room[CHAT_ROOM_URL_REVSHARE]
    end

    on 'newbies/:page/:new' do |page, new|
      rooms = datastore()
      rooms = rooms.select { |r| r[IS_NEW]=='true' }
      render_rooms(rooms, page, new)
    end

    on 'hd/:page/:new' do |page, new|
      rooms = datastore()
      rooms = rooms.select { |r| 
        r[IS_HD]=='true' 
      }
      render_rooms(rooms, page, new)
    end

    on root do
      res.redirect '/rooms/1'
    end
    on default do
      render(layout: true){ h1_ 'page not found'}
    end
  end
end
