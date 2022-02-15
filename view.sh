#!/usr/bin/env bash
# Id$ nonnax 2022-02-14 13:23:32 +0800
./view.rb "$1" | cattsv | fzf --preview='echo {} && mpv {+1}'
