#!/usr/bin/env ruby
# Id$ nonnax 2021-11-13 23:10:59 +0800
require 'benchmark'
loop do
  puts Benchmark.measure{
    puts 'fetching...'
    Thread.new{IO.popen("./cbph_nodown.rb", &:read)}.join
    puts 'ready!'
  }
  sleep 500
  
end
