#!/usr/bin/env bash
set -euo pipefail

# run as root
ddcutil --display 1 setvcp 10 0
ddcutil --display 2 setvcp 10 0
