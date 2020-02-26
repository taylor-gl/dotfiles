#!/bin/bash

DISABLEICON="<span color=\""$red"\">""</span>"

if [ "$BLOCK_BUTTON" = "1" ]; then
	~/.scripts/laptopkb/laptopkb-disable.sh
fi
echo $DISABLEICON
