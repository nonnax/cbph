#!/usr/bin/env bash
# Id$ nonnax 2021-11-14 15:04:36 +0800
echo "(ctrl+c to stop)"
# fd . media/ -e jpg -x rm {}
# cp 000000000_qrcode_top_show_fem_join_after_347.jpg media/
# cp zzzzzzzzzzz_qrcode_top_show_fem_join_after_346.jpg media/
# ./update_loop.rb & rackup -p 9393 && fg
while [ : ]
do
  echo "loading... "
  ./updatedb.rb
  echo "ready!"
  sleep $((5*60))
done
