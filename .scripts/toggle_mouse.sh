#!/bin/bash

# script to toggle left mouse button up/down.
# Initial run will create ~/.mouse-state.txt and will then toggle with subsequent runs.

if [ "$(cat ~/.mouse-state.txt)" = "0" ]; then
sleep 0.2 && xdotool mousedown 1 && echo 1 > ~/.mouse-state.txt
else
sleep 0.2 && xdotool mouseup 1 && echo 0 > ~/.mouse-state.txt
fi
