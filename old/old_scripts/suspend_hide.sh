#!/usr/bin/env bash
set -uo pipefail

file=~/.cache/hidden-windows
threshold=10

case $1 in
    "hide")
        id="$(xdo id)"
        pid="$(xdo pid)"
        wid=`xdotool getactivewindow`

        # suspend and hide
        kill -STOP $pid
        xdotool windowunmap $wid

        # append window name, window id, and pid to file
        echo -e $(xwininfo -id $id | cut -sd '"' -f2)'\t'$id'\t'$pid'\t'$wid >> $file ;;
    "unhide-pop")
        # resume and unhide
        window="$(tail -n 1 $file)"
        kill -CONT $(echo "$window" | cut -f3)
        xdotool windowmap $(echo "$window" | cut -f4)

        # delete from file
        wid="$(echo "$window" | cut -f4)"
        sed -i "/$wid/d" $file ;;
    "unhide-choose")
        # select, resume, and unhide
        window="$(rofi -dmenu -location 1 -width 100 -lines 6 -bw 0 -separator-style none -theme solarized -hide-scrollbar -i -l 15 -p "Unsuspend/unhide window:" < $file)"
        kill -CONT $(echo "$window" | cut -f3)
        xdotool windowmap $(echo "$window" | cut -f4)

        # delete from file
        wid="$(echo "$window" | cut -f4)"
        sed -i "/$wid/d" $file ;;
    "clear")
        while [[ $(wc -l $file | awk '{print $1}') -gt 0 ]]
        do
            window="$(head -n 1 $file)"
            wid="$(echo "$window" | cut -f4)"
            sed -i "/$wid/d" $file
            kill -CONT $(echo "$window" | cut -f3)
            kill -TERM $(echo "$window" | cut -f3)
        done ;;
    *)
        echo "ERROR: No valid option provided. Exiting..."
        exit 1
esac

# When processes exceed threshold, kill the oldest and remove it from file
if [[ $(wc -l $file | awk '{print $1}') -ge $threshold ]]; then
    window="$(head -n 1 $file)"
    wid="$(echo "$window" | cut -f4)"
    sed -i "/$wid/d" $file
    kill -CONT $(echo "$window" | cut -f3)
    kill -TERM $(echo "$window" | cut -f3)
fi
