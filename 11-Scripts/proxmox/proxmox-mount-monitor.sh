#!/bin/bash

# ----------------------------
# Mount Watchdog (Proxmox)
# TrueNAS mount monitoring
# Sequential LXC + VM handling
# Single Gotify notification on state change
# ----------------------------

declare -A LXC_LIST=(
    [1008]="/mnt/pve/backup"
    [1010]="/mnt/pve/torrent"
    [1011]="/mnt/pve/torrent"
)

declare -A VM_LIST=(
    [1101]="/mnt/pve/pxeiso"
    [1200]="/mnt/pve/torrent"
)

MAIN_MOUNT="/mnt/pve/backup"
STATE_FILE="/run/truenas-mount.state"

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Check if a mount point is accessible
check_mount() {
    timeout 2 ls "$1" >/dev/null 2>&1
}

# Determine current mount state (up/down)
get_mount_state() {
    if check_mount "$MAIN_MOUNT"; then
        echo "up"
    else
        echo "down"
    fi
}

# Handle LXC containers based on mount availability
handle_lxc() {
    ID=$1
    MOUNT=$2

    if check_mount "$MOUNT"; then
        # Start container if mount is available and container is not running
        if ! pct status $ID | grep -q "status: running"; then
            pct start $ID
        fi
    else
        # Stop container if mount is not available and container is running
        if pct status $ID | grep -q "status: running"; then

            # Special case: restic container (1008)
            if [ "$ID" == "1008" ]; then
                pct exec 1008 -- systemctl stop restic 2>/dev/null
                sleep 2
            fi

            pct stop $ID
        fi
    fi
}

# Handle virtual machines based on mount availability
handle_vm() {
    ID=$1
    MOUNT=$2

    if check_mount "$MOUNT"; then
        # Start VM if mount is available and VM is not running
        if ! qm status $ID | grep -q "status: running"; then
            qm start $ID
        fi
    else
        # Stop VM if mount is not available and VM is running
        if qm status $ID | grep -q "status: running"; then
            qm stop $ID
        fi
    fi
}

# ----------------------------
# Mount state monitoring (single notification on change)
# ----------------------------

OLD_STATE="unknown"
[ -f "$STATE_FILE" ] && OLD_STATE=$(cat "$STATE_FILE")

NEW_STATE=$(get_mount_state)
echo "$NEW_STATE" > "$STATE_FILE"

# Send Gotify notification only if state has changed
if [ "$OLD_STATE" != "$NEW_STATE" ]; then
    if [ "$NEW_STATE" == "down" ]; then
        /usr/local/bin/send-gotify.sh "⚠️ TrueNAS share is NOT accessible"
    else
        /usr/local/bin/send-gotify.sh "✅ TrueNAS share is accessible again"
    fi
fi

# ----------------------------
# Process LXC containers
# ----------------------------
for ID in "${!LXC_LIST[@]}"; do
    handle_lxc "$ID" "${LXC_LIST[$ID]}"
done

# ----------------------------
# Process virtual machines
# ----------------------------
for ID in "${!VM_LIST[@]}"; do
    handle_vm "$ID" "${VM_LIST[$ID]}"
done
