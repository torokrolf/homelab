#!/bin/bash

# Configuration
NAS_IP="192.168.2.220"
NFS_REMOTE="/mnt/ssdpool/torrent"       # TrueNAS NFS export path
NFS_LOCAL="/mnt/torrent"                 # Local mount point
QBIT_SERVICE="qbittorrent-nox.service"

# Infinite loop
while true; do
    # Check if the NAS is reachable on the network
    if ping -c 1 -W 1 $NAS_IP &>/dev/null; then
        echo "$(date) - NAS is reachable"

        # Check if the share is already mounted
        if ! mountpoint -q "$NFS_LOCAL"; then
            echo "$(date) - Mounting the NFS share..."
            mount -t nfs -o vers=4,soft,timeo=5,retrans=2 $NAS_IP:$NFS_REMOTE $NFS_LOCAL
            if [ $? -eq 0 ]; then
                echo "$(date) - NFS mount successful"
            else
                echo "$(date) - Error mounting NFS share"
            fi
        fi

        # Start qBittorrent if the mount is successful AND it's not already running
        if mountpoint -q "$NFS_LOCAL" && ! systemctl is-active --quiet $QBIT_SERVICE; then
            systemctl reset-failed $QBIT_SERVICE
            systemctl start $QBIT_SERVICE
            echo "$(date) - qBittorrent started"
        fi
    else
        echo "$(date) - NAS unreachable or connection lost"
        
        # Stop qBittorrent if the NAS is not reachable
        if systemctl is-active --quiet $QBIT_SERVICE; then
            echo "$(date) - qBittorrent stopped"
            systemctl stop $QBIT_SERVICE
        fi
        
        # Try to unmount the share if it's still mounted
        if mountpoint -q "$NFS_LOCAL"; then
            echo "$(date) - NFS share unmounted"
            umount -fl "$NFS_LOCAL"
        fi
    fi

    # Wait 30 seconds before the next check
    sleep 30
done
