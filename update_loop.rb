#!/usr/bin/env ruby
# Id$ nonnax 2021-11-13 23:10:59 +0800
loop do
  # start each run clean
  # IO.popen('fd . media/ -e jpg -x rm {}', &:read)
  puts 'fetching...'
  IO.popen("./cbph.rb", &:read)
  puts 'ready!'
  # reload media/
  # IO.popen('cp 000000000_qrcode_top_show_fem_join_after_347.jpg media/', &:read)
  # IO.popen('cp zzzzzzzzzzz_qrcode_top_show_fem_join_after_346.jpg media/', &:read)
  sleep 180
end
