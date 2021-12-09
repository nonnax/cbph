#!/usr/bin/env ruby
# Id$ nonnax 2021-12-01 17:34:07 +0800
require 'gdbm'

GDBM.open('users.db') do |gdbm|
  # gdbm.each_pair do |k, v|
    # p [k, v]
  # end
  p gdbm.to_hash
  p gdbm.size
  p gdbm.values.size
end

