#!/usr/bin/env bash
# checks if a server is running on PORT
RESULT=$(lsof -Pi :$PORT -sTCP:LISTEN)

if [ "$RESULT" = "" ]; then
    echo $NOT_BUSY_MESSAGE
else
    echo $BUSY_MESSAGE
fi
