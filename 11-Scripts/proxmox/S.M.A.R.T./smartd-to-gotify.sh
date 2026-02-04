#!/bin/bash
# ----------------------------
# smartd → Gotify Notification Script
# Sends SMART error alerts to a Gotify server
# ----------------------------

# Configuration (set your own Gotify server URL and API token)
GOTIFY_URL="http://YOUR_GOTIFY_SERVER:PORT/message"
GOTIFY_TOKEN="YOUR_GOTIFY_API_TOKEN"

# smartd provides these environment variables on error:
# $SMARTD_MESSAGE - description of the error
# $SMARTD_DEVICE  - affected disk device

MESSAGE="Disk error detected: $SMARTD_DEVICE\n\nDetails: $SMARTD_MESSAGE"

# Send notification to Gotify
curl -s -X POST "$GOTIFY_URL?token=$GOTIFY_TOKEN" \
    -F "title=⚠️ SMART ALERT - $(hostname)" \
    -F "message=$MESSAGE" \
    -F "priority=8"
