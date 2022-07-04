#!/bin/bash
user="taylor"
settings() {
    sudo -u $user timeout 5s nordvpn s protocol udp
    sudo -u $user timeout 5s nordvpn s killswitch on
    sudo -u $user timeout 5s nordvpn s cybersec on
    sudo -u $user timeout 5s nordvpn s obfuscate off
    sudo -u $user timeout 5s nordvpn s notify on
    sudo -u $user timeout 5s nordvpn s autoconnect on
    # timeout 5s nordvpn s dns off
}

reconnect() {
    sudo -u $user timeout 5s nordvpn d
    sudo -u $user timeout 5s nordvpn c p2p
}

restartvpnservices() {
    systemctl restart nordvpn.service | systemctl restart nordvpnd.service
}

check() {
    sudo -u $user timeout 5s bash -c 'nordvpn status | grep -q "Status: Connected"'
}

checkdis1() {
    sudo -u $user timeout 5s bash -c 'nordvpn d | grep -q "You are disconnected from NordVPN."'
}

checkdis2() {
    sudo -u $user timeout 5s bash -c 'nordvpn d | grep -q "You are not connected to NordVPN."'
}

# Connection check.
settings
reconnect
echo "$(date) [Checking VPN connectivity]"
if ! check; then
    echo "$(date) [Check failed, trying again in 3s]"
    sleep 3
    reconnect
    if ! check; then
        echo "$(date) [Reconnect failed, trying again in 3s]"
        sleep 3
        reconnect
        if ! check; then
            echo "$(date) [Second reconnect failed, restarting NordVPN (30s)"
            restartvpnservices
            sleep 30
            settings
            reconnect
            echo "$(date) [Checking VPN connectivity]"
            if ! check; then
                echo "$(date) [Check failed, trying again in 3s]"
                sleep 3
                reconnect
                if ! check; then
                    echo "$(date) [Check failed again, starting VPN]"
                    reconnect
                    if ! check; then
                        echo "$(date) [Reconnect failed, trying again in 3s]"
                        sleep 3
                        reconnect
                        if ! check; then
                            echo "$(date) [Second reconnect failed, restart the system to regain connection with the VPN service]"
                            sleep 99999999999999999999999999999999
                        fi
                    fi
                fi
            fi
        fi
    fi
fi

# Disconnect check to ensure it doesn't claim to be connected while it actually isn't. Blame NordVPN for this one, not the script.
if ! checkdis1; then
    echo "$(date) [Disconnect check failed, restarting NordVPN (30s)]"
    restartvpnservices
    sleep 30
    settings
    if ! checkdis2; then
        echo "$(date) [Disconnect check failed, restart the system to regain connection with the VPN service]"
        sleep 99999999999999999999999999999999
    fi
fi

# Final connection attempt activated when everything goes well.
reconnect
echo "$(date) [VPN connected!]"
sleep 5
