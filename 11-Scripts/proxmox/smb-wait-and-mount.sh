#!/usr/bin/env bash

# NOTE:
# This script was previously used to mount an SMB share on the Proxmox host
# provided by a Proxmox VM.
# It is no longer in use since the SMB service was migrated to TrueNAS.

# Wait until the SMB service becomes available
until nc -z -w3 192.168.2.200 445; do
  echo "Waiting for SMB service on 192.168.2.200..."
  sleep 3
done

mountpoint="/mnt/megosztasaim/torrent"
if ! mountpoint -q "$mountpoint"; then
  mount -t cifs //192.168.2.200/torrent "$mountpoint" \
    -o username=username,password=password,uid=0,gid=0,file_mode=0777,dir_mode=0777,_netdev
fi
