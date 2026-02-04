#!/bin/bash
# ----------------------------
# Mount Watchdog (Proxmox)
# Sequential start/stop for LXC + VM
# ----------------------------

declare -A LXC_LIST=(
    [1008]="/mnt/pve/backup"
    [1011]="/mnt/pve/torrent"
)

declare -A VM_LIST=(
    [1101]="/mnt/pve/pxeiso"
    [1200]="/mnt/pve/torrent"
)

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Check if the mount point is accessible
check_mount() {
    timeout 2 ls "$1" >/dev/null 2>&1
}

# Handle LXC containers
handle_lxc() {
    ID=$1
    MOUNT=$2
    NAME="lxc-$ID"

    if check_mount "$MOUNT"; then
        # Mount is OK, start container if not running
        if ! pct status $ID | grep -q "status: running"; then
            echo "$(date '+%F %T') - $NAME: mount OK, starting"
            pct start $ID
        fi
    else
        # Mount not accessible, stop container if running
        if pct status $ID | grep -q "status: running"; then
            echo "$(date '+%F %T') - $NAME: mount NOT accessible, stopping"

            # Special case: restic container (1008)
            if [ "$ID" == "1008" ]; then
                echo "$(date '+%F %T') - lxc-1008: stopping restic"
                pct exec 1008 -- systemctl stop restic 2>/dev/null
                sleep 2
            fi

            pct stop $ID
        fi
    fi
}

# Handle VMs
handle_vm() {
    ID=$1
    MOUNT=$2
    NAME="vm-$ID"

    if check_mount "$MOUNT"; then
        # Mount is OK, start VM if not running
        if ! qm status $ID | grep -q "status: running"; then
            echo "$(date '+%F %T') - $NAME: mount OK, starting"
            qm start $ID
        fi
    else
        # Mount not accessible, stop VM if running
        if qm status $ID | grep -q "status: running"; then
            echo "$(date '+%F %T') - $NAME: mount NOT accessible, stopping"
            qm stop $ID
        fi
    fi
}

# LXC containers
for ID in "${!LXC_LIST[@]}"; do
    handle_lxc "$ID" "${LXC_LIST[$ID]}"
done

# VMs
for ID in "${!VM_LIST[@]}"; do
    handle_vm "$ID" "${VM_LIST[$ID]}"
done
