#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-11-04 21:05:10 +0800
require 'rubytools/cubadoo'

Cuba.class_eval do
  def _layout(&block)
    Scooby.dooby do
      html do
        head do
          meta('http-equiv': 'refresh', content: '120')
          link(rel: 'stylesheet', type: "text/css",  href: '/css/style.css')
          # link(rel: 'stylesheet', type: 'text/css', href: '/media/style.css')
        end
        body do
          h1 { 'Layout here' }
          div(id: 'content', &block)
        end
      end
    end
  end
end

Cuba.define do
  on get do
    # /media/style.css
    on 'styler', extension('css') do |file|
      render(use_layout: true) { "Filename: #{file}" } #=> "Filename: style"
    end
    # /search?q=barbaz
    on 'search', param('q') do |query|
      render(use_layout: true) do
        div { "You Searched for #{query}" } #=> "Searched for barbaz"
      end
    end

    rooms = File.read('./data.txt').split("\n")

    on 'rooms/:page' do |pg|
      page=pg.to_i-1
      offset=200
      pages=(rooms.size/offset.to_f).ceil
      
      render(use_layout: true) do
        div do
          p do
            # "page #{page+1} of #{pages}"
            "room(s): #{page*offset}..#{(page*offset+offset-1)}"
          end
          p do            
            pages.times do |i|
              a( href: "/rooms/#{i+1}"){ b(class: 'page'){"#{i+1}"} }
              span{'&nbsp;&nbsp;'}
            end
          end
          rooms[page*offset..(page*offset+offset-1)].each do |u|
            i, user, loc, _, iframe_embbed = u.split('\\')
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
    
    on root do
      res.redirect '/rooms/1'
    end
    on default do
      res.html 'page not found'
    end
  end
end

