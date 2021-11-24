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
          # link(rel: 'stylesheet', type: "text/css",  href: '/css/style.css')
          link(rel: 'stylesheet', type: 'text/css', href: '/media/style.css')
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
    on root do
      render(use_layout: true) do
        div do
          p { "number of rooms: #{rooms.uniq.size}" }
          rooms.uniq.each do |u|
            i, user, loc, _, iframe_embbed = u.split('\\')
            div(class: 'grid') do
              a(href: "https://chaturbate.com/#{user}/") { img(src: "/media/#{user}.jpg") }
              div(class: 'user') { 
                p{ user  }
                p{ loc } 
              }
            end
          end
        end
      end
    end
  end
end

