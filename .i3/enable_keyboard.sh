#!/bin/bash

ENABLEICON="<span color=\""$green"\">""</span>"

if [ "$BLOCK_BUTTON" = "1" ]; then
	~/.scripts/laptopkb/laptopkb-enable.sh
fi
echo $ENABLEICON
