#!/usr/bin/env bash

# based on this reddit comment: https://www.reddit.com/r/i3wm/comments/dxyig7/i3_gnome_like_calendar_popuup/f7xyk3i/

faketty () {
script -qfec "$(printf "%q " "$@")"
}

cal_out=$(faketty cal --three | sed 's|\x1b\[[0-9;]*m\(.*\)\x1b\[[0-9;]*m|<span color="orange">\1</span>|g')

rofi -theme-str 'window {width: 66ch; font: "FantasqueSansMono Nerd Font Mono 12"; location: south east; anchor: south east; y-offset: -22 px;}' -markup -e "${cal_out}"
