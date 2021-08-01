#!/usr/bin/env bash
set -euo pipefail

TOGGLE=$HOME/.toggle_loopback

if [ ! -e $TOGGLE ]; then
    touch $TOGGLE
    pactl load-module module-loopback latency_msec=1
else
    rm $TOGGLE
    pactl unload-module module-loopback
fi
