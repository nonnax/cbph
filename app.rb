#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-11-04 21:05:10 +0800
require 'rubytools/cubadoo'
require 'csv'
require 'cgi'

Cuba.class_eval do
  def _layout(&block)
    Scooby.dooby do
      html do
        head do
          meta('http-equiv': 'refresh', content: '120')
          # link(rel: 'stylesheet', type: "text/css",  href: '/css/style.css')
          link(rel: 'stylesheet', type: 'text/css', href: '/css/style001.css')
        end
        body do
          h1 { 'Layout here' }          
          p do
            form(action: '/search', method: 'get') do
              input( type: 'text', name: 'q' )
              input( type: 'submit', value: 'search')
            end
          end
          div(id: 'content', &block)
        end
      end
    end
  end
  def location_links(rooms)
     Scooby.dooby do
        div do
          rooms.map{|r| r[2] }.uniq.map do |loc|
            a( href: "/search/#{loc}/1"){ loc }
            span{'&nbsp;'}
          end
        end
     end
  end

  def page_info(page, pages, offset=200)
     Scooby.dooby do
        p do
          "(#{page+1} of #{pages})"
        end
     end
  end
  
  def rooms_tile(vrooms, page)
    rooms=vrooms.uniq.sort_by{|r| r[-2].to_i }.reverse
    offset=200
    Scooby.dooby do
      div do
          rooms[page*offset..(page*offset+offset-1)].map do |u|
            i, user, loc, age, num_followers, chat_room_url_revshare = u
            div(class: 'grid') do
              div(class: 'center'){a( href: chat_room_url_revshare, target: "_blank") { img(src: "/media/#{user}.jpg") }}
              div(class: 'user') { 
                p{ user  }
                p{ loc } 
                p{ num_followers } 
              }
            end            
          end
      end    
    end
  end
  
  def render_rooms(vrooms, q='', pg=1 )
      rooms=vrooms
      page=pg.to_i-1
      offset=200
      pages=(rooms.size/offset.to_f).ceil
      links=location_links(rooms)
      rooms_tile_view=rooms_tile(rooms, page)
      page_info_view=page_info(page, pages)
      render(use_layout: true) do
        div do
          p { page_info_view }
          p do            
            pages.times do |i|
              a( href: "/search/#{q}/#{i+1}"){ b(class: 'page'){"#{i+1}"} }
              span{'&nbsp;&nbsp;'}
            end
          end
          p{ links }
          p{ rooms_tile_view }
          div(class: 'clearfix'){ hr }
          p{ links }
        end
      end    
  end
end



Cuba.define do
  rooms = CSV.read('./data.csv')

  on get do
    # /media/style.css
    on 'styler', extension('css') do |file|
      render(use_layout: true) { "Filename: #{file}" } #=> "Filename: style"
    end
    # /search?q=barbaz
    on 'search', param('q') do |q|
      res.redirect "/search/#{q}/1"
    end

    on 'rooms/:page' do |pg|
      page=pg.to_i-1
      offset=200
      pages=(rooms.size/offset.to_f).ceil
      rooms_tile_view=rooms_tile(rooms, page)
      page_info_view=page_info(page, pages)
      render(use_layout: true) do
        div do
          p { page_info_view }
          p do            
            pages.times do |i|
              a( href: "/rooms/#{i+1}"){ b(class: 'page'){ "#{i+1}" } }
              span{'&nbsp;&nbsp;'}
            end
          end
          p { rooms_tile_view }
        end
      end
    end

    on 'search/:loc/:page' do |loc, page|
       loc_decoded=CGI.unescape(loc)
       rooms = CSV.read('./data.csv')
       rooms=rooms.select{|r| (/#{loc_decoded}/i).match(r[2])}
       render_rooms(rooms,loc,page)
    end    
    on root do
      res.redirect '/rooms/1'
    end
    on default do
      res.html 'page not found'
    end
  end
end

