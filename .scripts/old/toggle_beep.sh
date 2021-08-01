#!/usr/bin/env bash
set -euo pipefail

TOGGLE=$HOME/.toggle_beep

if [ ! -e $TOGGLE ]; then
    touch $TOGGLE
    echo "enabled periodic beep timer"
else
    rm $TOGGLE
    echo "disabled periodic beep timer"
fi
