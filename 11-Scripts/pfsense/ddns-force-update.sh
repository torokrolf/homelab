#!/bin/sh

# Get current public IP address
NEW_IP=$(curl -s https://checkip.amazonaws.com/)
[ -z "$NEW_IP" ] && exit 1

# Read last known IP (if exists)
OLD_IP=$(cat /var/db/current_ip.txt 2>/dev/null)

# Trigger DDNS update only if IP has changed
if [ "$NEW_IP" != "$OLD_IP" ]; then
  echo "$NEW_IP" > /var/db/current_ip.txt
  /etc/rc.dyndns.update
fi
