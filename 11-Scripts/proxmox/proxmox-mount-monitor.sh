#!/bin/bash

# ----------------------------
# Mount Watchdog (Proxmox)
# TrueNAS mount figyelés
# LXC + VM szekvenciális kezelés
# Egy darab Gotify értesítéssel
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

check_mount() {
    timeout 2 ls "$1" >/dev/null 2>&1
}

get_mount_state() {
    if check_mount "$MAIN_MOUNT"; then
        echo "up"
    else
        echo "down"
    fi
}

handle_lxc() {
    ID=$1
    MOUNT=$2

    if check_mount "$MOUNT"; then
        if ! pct status $ID | grep -q "status: running"; then
            pct start $ID
        fi
    else
        if pct status $ID | grep -q "status: running"; then

            # Speciális: restic container (1008)
            if [ "$ID" == "1008" ]; then
                pct exec 1008 -- systemctl stop restic 2>/dev/null
                sleep 2
            fi

            pct stop $ID
        fi
    fi
}

handle_vm() {
    ID=$1
    MOUNT=$2

    if check_mount "$MOUNT"; then
        if ! qm status $ID | grep -q "status: running"; then
            qm start $ID
        fi
    else
        if qm status $ID | grep -q "status: running"; then
            qm stop $ID
        fi
    fi
}

# ----------------------------
# Mount állapot figyelés (egyszeri notify)
# ----------------------------

OLD_STATE="unknown"
[ -f "$STATE_FILE" ] && OLD_STATE=$(cat "$STATE_FILE")

NEW_STATE=$(get_mount_state)
echo "$NEW_STATE" > "$STATE_FILE"

if [ "$OLD_STATE" != "$NEW_STATE" ]; then
    if [ "$NEW_STATE" == "down" ]; then
        /usr/local/bin/send-gotify.sh "⚠️ TrueNAS megosztás NEM elérhető"
    else
        /usr/local/bin/send-gotify.sh "✅ TrueNAS megosztás újra elérhető"
    fi
fi

# ----------------------------
# LXC-k feldolgozása
# ----------------------------
for ID in "${!LXC_LIST[@]}"; do
    handle_lxc "$ID" "${LXC_LIST[$ID]}"
done

# ----------------------------
# VM-ek feldolgozása
# ----------------------------
for ID in "${!VM_LIST[@]}"; do
    handle_vm "$ID" "${VM_LIST[$ID]}"
done
