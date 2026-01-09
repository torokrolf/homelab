#!/data/data/com.termux/files/usr/bin/bash

# SSH connection details
USER="root"
HOST="192.168.2.208"

# Get current Pi-hole status (check if blocking is enabled)
STATUS=$(ssh $USER@$HOST "pihole status | grep enabled")

if [ -n "$STATUS" ]; then
    # If Pi-hole is currently enabled, disable it
    ssh $USER@$HOST "pihole disable"
    termux-toast "Pi-hole permanently disabled"
else
    # If Pi-hole is currently disabled, enable it
    ssh $USER@$HOST "pihole enable"
    termux-toast "Pi-hole enabled"
fi
