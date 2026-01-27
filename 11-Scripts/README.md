← [Back to Homelab Home](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Scripts

---

## pfSense
- **[ddns-force-update.sh](./pfsense/ddns-force-update.sh)** – Script running on the pfSense firewall to manually trigger a DDNS update when the IP changes.

---

## Powershell

- **[restic-backup-and-shutdown.ps1](./windows/restic-backup-and-shutdown.ps1)** – Performs a Restic backup and then automatically shuts down the machine.

---

## Proxmox

- **[smb-vm-mount.sh](./proxmox/smb-vm-mount.sh)** – Previously used on the Proxmox host to mount an SMB share provided by a VM running on the same host. Due to a race condition, it could fail because Proxmox tries to mount before the VM is up. No longer in use, as TrueNAS on a separate Proxmox host now provides the shares to VMs.  
- **[smb-vm-mount.service](./proxmox/smb-vm-mount.service)** – systemd service that runs the mount script (**smb-vm-mount.sh**) once at boot.

---

## qBittorrent + NFS (TrueNAS)

- **nfs_qbittorrent.sh** – Script that continuously checks if the TrueNAS NFS share is available. If yes, it mounts the share and starts the **qbittorrent-nox** service; if the share disappears, it stops qBittorrent and unmounts the share.  
- **nfs_qbittorrent.service** – systemd service that automatically runs **nfs_qbittorrent.sh** at boot and keeps it running. Ensures qBittorrent only runs when the NAS is available.

---

## Termux / Android

- **toggle_pihole_ssh.sh** – Bash script running in Termux to toggle Pi-hole on or off via SSH. Useful when a webpage is blocked by Pi-hole; a single tap on the phone can quickly enable or disable it. The script checks the current state and applies the appropriate action, sending a toast notification on Android.

---

← [Back to Homelab Home](../README.md)


