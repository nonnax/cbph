#!/usr/bin/env ruby
# Id$ nonnax 2021-11-13 23:10:59 +0800
loop do
  IO.popen("cbph.rb", &:read)
  sleep 60
end
