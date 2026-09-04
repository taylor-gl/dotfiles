#!/usr/bin/env bash
set -euo pipefail

current1=$(ddcutil --display 1 getvcp 10 | awk '{ print $9 }' | sed 's/,//')
current2=$(ddcutil --display 2 getvcp 10 | awk '{ print $9 }' | sed 's/,//')
current3=$(ddcutil --display 3 getvcp 10 | awk '{ print $9 }' | sed 's/,//')

new1=$(( current1 < 50 ? current1 : 50))
new2=$(( current2 < 50 ? current2 : 50))
new3=$(( current3 < 50 ? current3 : 50))

# run as root
ddcutil --display 1 setvcp 10 $new1
ddcutil --display 2 setvcp 10 $new2
ddcutil --display 3 setvcp 10 $new3
