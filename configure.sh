#!/bin/bash
# An idempotent script which will configure a fresh Debian install to my liking

# Ensure the home variable is set to user directory
# (Script should be run with sudo -E)
if [[ -z "${HOME}" || "${HOME}" = '/root' ]]; then
    echo "The HOME variable is unset or is root! Run this script with sudo -E"
    exit 1;
fi

# Ensure the script is run as root
# (Script should be run with sudo -E)
if ! whoami | grep -q root ; then
    echo "You are not root! Run this script with sudo -E"
    exit 1;
fi

# Set the database used by locate command
echo "Setting the locatedb database"
rm /var/cache/locate/locatedb &> /dev/null
updatedb --localpaths=$HOME
# TODO: make this also set a root cron job to do this daily
