#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-11-04 21:05:10 +0800
require 'rubytools/cubadoo'
require 'csv'
require 'cgi'

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
              input_(type: 'text', name: 'q')
              input_(type: 'submit', value: 'search')
            end
          end
        end
        div_(id: 'content', &block)
      end
    end
  end

  def location_links(rooms)
    div_(class: 'location') do
      rooms.map { |r| r[2] }.uniq.map do |loc|
        a_(class: 'page', href: "/search/#{loc}/1") { loc }
      end
    end
  end

  def page_info(page, pages, _offset = 200)
    div_ do
      "(#{page + 1} of #{pages})"
    end
  end

  def rooms_tile(vrooms, page)
    rooms = vrooms.uniq.sort_by { |r| r[-2].to_i }.reverse
    offset = 200

    div_ do
      rooms[page * offset..(page * offset + offset - 1)].map do |u|
        i, user, loc, age, num_followers, chat_room_url_revshare = u
        div_(class: 'grid') do
          div_(class: 'center') do
            a_(href: chat_room_url_revshare, target: '_blank') do
              img_(src: "/media/#{user}.jpg")
            end
          end
          div_(class: 'user') do
            p_ { user }
            p_ { loc }
            p_ { num_followers }
          end
        end
      end
    end
  end

  def render_rooms(vrooms, q = '', pg = 1)
    rooms = vrooms
    page = pg.to_i - 1
    offset = 200
    pages = (rooms.size / offset.to_f).floor
    links = location_links(rooms)
    rooms_tile_view = rooms_tile(rooms, page)
    page_info_view = page_info(page, pages)
    render(layout: true) do
      div_ do
        p_ { page_info_view }
        div_(class: 'pages') do
          pages.times do |i|
            a_(class: 'page', href: "/search/#{q}/#{i + 1}") { b_ { (i + 1) } }
          end
        end
        p_ { links }
        p_ { rooms_tile_view }
        div_(class: 'clearfix') { hr_ }
        p_ { links }
      end
    end
  end
end

Cuba.define do
  rooms = CSV.read('./data.csv')

  on get do
    # /media/style.css
    on 'styler', extension('css') do |file|
      render(layout: true) { "Filename: #{file}" } #=> "Filename: style"
    end
    # /search?q=barbaz
    on 'search', param('q') do |q|
      res.redirect "/search/#{q}/1"
    end

    on 'rooms/:page' do |pg|
      page = pg.to_i - 1
      offset = 200
      pages = (rooms.size / offset.to_f).floor
      rooms_tile_view = rooms_tile(rooms, page)
      page_info_view = page_info(page, pages)
      render(layout: true) do
        div_ do
          p_ { page_info_view }
          div_(class: 'pages') do
            pages.times do |i|
              a_(class: 'page', href: "/rooms/#{i + 1}") { b_{ i + 1 } }
              span_ { ' ' }
            end
          end
          p_ { rooms_tile_view }
        end
      end
    end

    on 'search/:loc/:page' do |loc, page|
      loc_decoded = CGI.unescape(loc)
      rooms = CSV.read('./data.csv')
      rooms = rooms.select { |r| (/#{loc_decoded}/i).match(r[2]) }
      render_rooms(rooms, loc, page)
    end
    on root do
      res.redirect '/rooms/1'
    end
    on default do
      render(layout: true){ h1_ 'page not found'}
    end
  end
end
