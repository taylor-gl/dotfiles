#!/usr/bin/env bash
set -euo pipefail

TOGGLE=$HOME/.toggle_beep

# set user
export XDG_RUNTIME_DIR=/run/user/1000

if [ -e $TOGGLE ]; then
    paplay "/home/taylor/Dropbox/Videos/Good Sounds/Shenmue2Delin.wav"
fi
