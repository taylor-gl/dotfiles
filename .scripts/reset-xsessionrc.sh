#!/bin/bash

XSESSIONRC_PATH="/home/taylor/.xsessionrc"

echo "Resetting .xsessionrc: $(date)" >> /tmp/reset-xsessionrc.log

sleep 2

$XSESSIONRC_PATH
