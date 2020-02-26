#!/bin/bash

# Left click
if [[ "${BLOCK_BUTTON}" -eq 1 ]]; then
  xbacklight + 10
# Middle click
elif [[ "${BLOCK_BUTTON}" -eq 2 ]]; then
  xbacklight -set 100
# Right click
elif [[ "${BLOCK_BUTTON}" -eq 3 ]]; then
  xbacklight - 10
fi

statusLine=$(xbacklight)
bright=$(echo "${statusLine}" | colrm 4)

  echo "${bright}%"
  echo ""
