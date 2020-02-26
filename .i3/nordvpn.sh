#!/bin/bash

DISCONNECTED="<span color=\""$red"\">""</span>"
CONNECTED="<span color=\""$green"\">""</span>"

STATUS=`nordvpn status | head -1`
if [ "$STATUS" = "Status: Connected" ]; then
    if [ "$BLOCK_BUTTON" = "1" ]; then
        nordvpn disconnect > /dev/null;
    fi
    echo $CONNECTED
else
    if [ "$BLOCK_BUTTON" = "1" ]; then
        nordvpn connect canada -g p2p > /dev/null;
    fi
    echo $DISCONNECTED
fi
