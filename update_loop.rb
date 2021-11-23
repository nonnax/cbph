#!/usr/bin/env ruby
# Id$ nonnax 2021-11-13 23:10:59 +0800
loop do
  puts 'fetching...'
  IO.popen("./cbph.rb", &:read)
  puts 'ready!'
  sleep 180
end
