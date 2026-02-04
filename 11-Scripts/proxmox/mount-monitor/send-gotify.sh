#!/bin/bash
# ----------------------------
# Gotify Notification Script
# Sends a message to a Gotify server via API
# ----------------------------

# Configuration (set your own Gotify server URL and API token here)
GOTIFY_URL="http://YOUR_GOTIFY_SERVER:PORT/message"
GOTIFY_TOKEN="YOUR_GOTIFY_API_TOKEN"

# First argument: message text to send
MESSAGE="$1"

# Exit if no message was provided
if [ -z "$MESSAGE" ]; then
    echo "Usage: $0 \"Message text\""
    exit 1
fi

# Send notification as JSON payload
curl -s -X POST "$GOTIFY_URL" \
     -H "X-Gotify-Key: $GOTIFY_TOKEN" \
     -H "Content-Type: application/json" \
     -d "{\"message\":\"$MESSAGE\",\"priority\":5}" >/dev/null 2>&1
