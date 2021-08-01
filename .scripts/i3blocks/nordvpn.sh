#!/usr/bin/env bash
RESULT=$(nordvpn status | sed '1{/"application"/!d}' | head -n1 | tr -d '\r' | awk '{ print $NF }')
echo VPN $RESULT
