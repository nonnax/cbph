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
        rooms.map{|r| r[2] }.uniq.each do |loc|
          a( href: "/search/#{loc}/1"){ loc }
          span{'&nbsp;'}
        end
     end
  end
  
  def render_rooms(rooms, q='*', pg=1 )
      page=pg.to_i-1
      offset=200
      pages=(rooms.size/offset.to_f).ceil
      
      render(use_layout: true) do
        div do
          p do
            "room(s): #{page*offset}..#{(page*offset+offset-1)} (#{page+1}/#{pages})"
          end
          p do            
            pages.times do |i|
              a( href: "/search/#{q}/#{i+1}"){ b(class: 'page'){"#{i+1}"} }
              span{'&nbsp;&nbsp;'}
            end
          end
          p do
            rooms.map{|r| r[2] }.uniq.each do |loc|
              a( href: "/search/#{loc}/1"){ loc }
              span{'&nbsp;'}
            end
          end
          rooms[page*offset..(page*offset+offset-1)].each do |u|
            i, user, loc, _, iframe_embbed = u#.split('\\')
            div(class: 'grid') do
              div(class: 'center'){a(href: "https://chaturbate.com/#{user}/") { img(src: "/media/#{user}.jpg") }}
              div(class: 'user') { 
                p{ user  }
                p{ loc } 
              }
            end            
          end
          div(class: 'clearfix'){
            hr
          }
          p do
            rooms.map{|r| r[2] }.uniq.each do |loc|
              a( href: "/search/#{loc}/1"){ loc }
              span{'&nbsp;'}
            end
          end
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
      
      render(use_layout: true) do
        div do
          p do
            "room(s): #{page*offset}..#{(page*offset+offset-1)} (#{page+1}/#{pages})"
          end
          p do            
            pages.times do |i|
              a( href: "/rooms/#{i+1}"){ b(class: 'page'){"#{i+1}"} }
              span{'&nbsp;&nbsp;'}
            end
          end
          rooms[page*offset..(page*offset+offset-1)].each do |u|
            i, user, loc, _, iframe_embbed = u#.split('\\')
            div(class: 'grid') do
              div(class: 'center'){a(href: "https://chaturbate.com/#{user}/") { img(src: "/media/#{user}.jpg") }}
              div(class: 'user') { 
                p{ user  }
                p{ loc } 
              }
            end            
          end
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

