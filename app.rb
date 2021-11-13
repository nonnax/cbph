#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-11-04 21:05:10 +0800
require 'cubadoo'

Cuba.define do
  on get do
    rooms = File.read('./data.txt').split("\n")
    on root do
      render do
        html do
          head do
            meta( 'http-equiv': "refresh", content: "30")
            style do
              # grid-template-columns: repeat( auto-fit, minmax(320px, 1fr) ); auto-fit or auto-fill?
              %(
                .grid {
                  float: left;
                  # display: grid;
                  # grid-template-columns: repeat( auto-fill, minmax(240px, 1fr) );
                  clear: right;
                }
                p{
                  # width: 90%;
                  clear: both;
                }
               )
            end
          end
          body do
            rooms.uniq.each_slice(3) do |cut|
              p do
              cut.each do |u|
                i, user, loc, = u.split('\\')
                div(class: 'grid') do                
                  a(href: "https://chaturbate.com/#{user}/") { img( src: ['',:media, "#{user}.jpg"].join('/')) }
                  p{loc}
                end
              end
              end
            end
          end
        end
      end
    end
  end
end
