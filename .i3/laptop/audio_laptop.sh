#!/bin/bash

# https://github.com/Anachron/i3blocks

# Left click
if [[ "${BLOCK_BUTTON}" -eq 1 ]]; then
  pactl set-sink-volume 0 +10%
# Middle click
elif [[ "${BLOCK_BUTTON}" -eq 2 ]]; then
  pactl set-sink-mute 0 toggle
# Right click
elif [[ "${BLOCK_BUTTON}" -eq 3 ]]; then
  pactl set-sink-volume 0 -10%
fi

statusLine=$(amixer -c 1 get Master | tail -n 1)
status=$(echo "${statusLine}" | grep -wo "on")
volume=$(pactl list sinks | grep '^[[:space:]]Volume:' | \
    head -n $(( $SINK + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')

if [[ "${status}" == "on" ]]; then
  echo "${volume}%"
  echo "${volume}%"
  echo ""
else
  echo "off"
  echo "off"
  echo ""
fi
