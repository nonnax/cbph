#!/usr/bin/env ruby
# Id$ nonnax 2021-11-04 21:08:46 +0800
require './app'
require 'rubytools/cache'

def reload(&block)
  ttl=block.call
  res = Cache.cached('reload', ttl: ttl) do
    p ['reloading...', IO.popen('./get.rb', &:read) ]
  end 
end

reload{ 300 * 6 }

run Cuba
