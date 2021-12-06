#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-11-04 21:05:10 +0800
require 'csv'
require 'cgi'
require_relative 'cb/helpers'

Cuba.define do
  rooms = datastore()

  on get do

    on 'search', param('q') do |q|
      res.redirect "/search/1/#{q}"
    end

    on 'rooms/:page' do |pg|
      page = pg.to_i - 1
      offset = OFFSET
      pages = (rooms.size / offset.to_f).floor
      montage_view = montage(rooms, page)
      _pagination_pages=_pagination(page, pages)
      render(layout: true) do
        div_ do
          p_ {_pagination_pages}
          p_ { montage_view }
          div_(class: 'clearfix') { hr_ }
          p_ {_pagination_pages}
        end
      end
    end

    on 'search/:page/:loc' do |page, loc|
      loc_decoded=un(loc)
      rooms = datastore()
      rooms = rooms.select { |r| (/#{loc_decoded}/i).match(r[LOCATION]) || (/#{loc_decoded}/i).match(r[USERNAME]) }
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

    on 'pickph/:page/:new' do |page, new|
      rooms = datastore()
      picklist=data_picklist()
      rooms = rooms.select { |r| picklist.include?(r[USERNAME]) }
      render_rooms(rooms, page, new)
    end

    on 'hd/:page/:new' do |page, new|
      rooms = datastore()
      rooms = rooms.select { |r| r[IS_HD]=='true' }
      render_rooms(rooms, page, new)
    end

    on 'pick/:username' do |username|
      rooms = pick_toggle(username)
      res.redirect req.referrer
    end

    on 'group/:page/:age' do |page, age|
      rooms = datastore()
      rooms = rooms.select { |r| 
        real_age=r[AGE].to_i
        case age
          when 'teen'
            (17..19).include?real_age
          when '20s'
            (20..24).include?real_age
          when '25up'
            (25..29).include?real_age
          when '30up'
            (30..40).include?real_age
          else
            real_age.zero?
        end
      }
      render_rooms(rooms, page, age)
    end

    on root do
      res.redirect '/rooms/1'
    end

    on default do
      render(layout: true){ div_(class: 'notice'){ div_(class: 'alert'){'W00ps! That was embarassing...'} }}
    end
    
  end
end
