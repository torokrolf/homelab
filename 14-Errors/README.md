← [Back to Homelab main page](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Errors

## 📚 Table of Contents

- [DNS – Public domain name resolution without internet](#dns--public-domain-name-resolution-without-internet)
- [DNS – Pi-hole blocks Google image results on mobile](#dns--pi-hole-blocks-google-image-results-on-mobile)
- [SSH – SSH login in LXC / Ubuntu](#ssh--ssh-login-in-lxc--ubuntu)
- [Sharing – SMB access from LXC](#sharing--smb-access-from-lxc)
- [Race condition – SMB mount ordering](#race-condition--smb-mount-ordering)
- [Sharing – Dynamic NFS mount for qBittorrent VM with race condition handling](#sharing--dynamic-nfs-mount-for-qbittorrent-vm-with-race-condition-handling-and-qbittorrent-shutdown-on-share-loss)
- [Hardware – External SSD stability over USB](#hardware--external-ssd-stability-over-usb--via-tp-link-ue330-vs-direct-usb-connection)
- [Hardware – M70q network adapter instability](#hardware--m70q-internal-network-adapter-instability---solution-with-external-usb-adapter-tp-link-ue330)
- [Hardware – Local and public DNS issues caused by Wi-Fi adapter](#hardware--local-and-public-dns-issues-caused-by-laptops-wi-fi-adapter)
- [DDNS – DDNS not updating on Cloudflare behind pfSense](#ddns--ddns-not-updating-on-cloudflare-due-to-private-ip-on-pfsense-wan-interface)

---

## DNS – Public domain name resolution without internet

**Problem:**
- The `*.trkrolf.com` domain (e.g. `zabbix.trkrolf.com`) is a public domain pointing to Cloudflare nameservers, which returned the **192.168.2.202 Nginx IP**.
- If the homelab had **no internet connection**, the domain could not be resolved because public DNS servers were unreachable.

**Solution:**
- **DNS override / local BIND9 DNS**: all `*.trkrolf.com` queries are handled by the local DNS server.
- This ensures that even without internet access, the domain always resolves to **192.168.2.202 (Nginx)**.

---

## DNS – Pi-hole blocks Google image results on mobile

**Problem**
- On mobile phones, when using Google search and clicking **image results**:
  - the target page often does not open
  - or the image does not redirect to the source website
- On desktop, this issue occurs rarely or not at all

**Cause**
- On mobile, Google image results **do not link directly to image files**, but go through:
  - advertising
  - tracking
  - redirect domains
- These domains are commonly included in **Pi-hole blocklists**, such as:
  - `googleadservices.com`
  - `googletagservices.com`
  - `doubleclick.net`
- When clicking an image, Google redirects through a tracking URL, which Pi-hole blocks at the DNS level
- Some image/CDN domains (e.g. certain `gstatic.com` subdomains) may also be blocked

**Note**
- This behavior is **not a Pi-hole bug**, but a natural consequence of ad and tracker blocking
- These domains are **intentionally blocked** by many default and community-maintained blocklists

**Solution I use**
- Temporarily disabling Pi-hole (e.g. via SSH from mobile using a script)

**Alternative solution (not recommended by me)**
- Selective whitelisting of domains (can reintroduce ads and tracking)

❗ Script implementation:  
[scripts/smb-vm-mount.sh](/11-Scripts/Android/toggle_pihole_ssh.sh)

---

## SSH – SSH login in LXC / Ubuntu

**Problem:**
- In LXC containers, only the root user exists by default, and root SSH login is disabled

**Recommended solution:**
- Create a regular user
- Allow SSH login using password or SSH keys

**Not recommended:**
- Enabling root SSH login (`PermitRootLogin yes`)
- Allowing direct root login via password or key

---

## Sharing – SMB access from LXC

**Problem:**  
- An unprivileged LXC container cannot mount SMB/CIFS shares directly

**Solution:**  
- Mount the SMB/CIFS share on the Proxmox host
- Pass the mounted directory into the LXC container using a bind mount (`mp0:`)
- Ensure correct permissions (uid/gid, file_mode/dir_mode) so the share is writable inside the container

**Security**
- Privileged LXC containers *can* mount SMB shares, but the container root equals the Proxmox host root → **security risk**
- Unprivileged LXC + host-side mount is safe and functional: the container root has lower privileges and cannot perform dangerous operations on the host

---

## Race condition – SMB mount ordering

**Problem:**  
- During Proxmox boot, it attempted to mount an SMB share provided by a VM running on the same host
- The VM was not running yet, so the mount failed due to a race condition

**Why systemd is better than fstab for network mounts:**  
- Network mounts (NFS, CIFS/Samba) may fail if the network or remote service is not ready
- With `fstab`, the mount may fail silently at boot
- Local disks work well with `fstab` because no race condition exists
- For network shares, **systemd services are the correct solution**, as they can wait for prerequisites

**Correct order:**  
1. Proxmox host boots
2. systemd service starts
3. Service pings the VM (ExecStartPre)
4. If the VM responds → mount script runs
5. Script checks SMB port (445) and mounts only when available
6. Successful mount → LXC containers can access the share

**Solution:**  
- systemd service checks VM availability
- Mount script checks SMB port availability
- Single mount attempt when conditions are met
- Race condition is eliminated

❗ Script:  
[scripts/smb-vm-mount.sh](/11-Scripts/proxmox/smb-vm-mount.sh)  
❗ systemd service:  
[scripts/smb-vm-mount.service](/11-Scripts/proxmox/smb-vm-mount.service)

---

## Sharing – Dynamic NFS mount for qBittorrent VM with race condition handling and qBittorrent shutdown on share loss

**Important:**  
Originally I used SMB. When TrueNAS was running, qBittorrent started correctly, but if TrueNAS was stopped afterward, qBittorrent kept running. SMB does not handle unexpected disconnects well, and even the `df` command could freeze.  
After switching to **native NFS**, the issue was completely resolved.

**Problem:**  
- On boot, systemd starts services
- qBittorrent may start before the TrueNAS share is mounted
- This can cause errors or downloads to be written to the local disk
- Similar issues occur if TrueNAS is unexpectedly shut down

**Solution:**  
- A daemon script checks storage availability every 30 seconds
- If NAS is available:
  - Mounts the NFS share
  - Starts qBittorrent only after a successful mount
- If NAS goes offline:
  - Immediately stops qBittorrent
  - Cleanly unmounts the share

**Implementation:**
- Infinite loop script
- Mounts/unmounts based on NAS availability
- Managed by systemd for auto-start and restart

---

## Hardware – External SSD stability over USB (TP-Link UE330 vs direct USB)

**Problem:**  
- A **Samsung 870 EVO** external SSD occasionally disconnected when plugged directly into USB

**Solution:**  
- Connecting the SSD through a **TP-Link UE330 USB hub**
- Stable operation for over 6 months
- Likely due to more stable power delivery

---

## Hardware – M70q internal network adapter instability  
### Solution: external USB adapter (TP-Link UE330)

**Problem**
- The internal NIC on an M70q occasionally drops the connection
- Remote access (SSH) becomes impossible until manual intervention

**Possible solution**
- Script to ping a device (e.g. router) and restart the adapter on failure

**Chosen solution**
- Using a **TP-Link UE330 USB network adapter**
- Stable operation for over 6 months

---

## Hardware – Local and public DNS issues caused by laptop Wi-Fi adapter

### Problem
- Local DNS sometimes failed to resolve internal hosts
- Occasionally even public domains (e.g. google.com) failed
- MediaTek 7921 Wi-Fi adapter caused instability on Linux

### Solution
- Replaced MediaTek 7921 with **Intel AX210**
- DNS resolution is now stable for both local and public domains

---

## DDNS – DDNS not updating on Cloudflare due to private IP on pfSense WAN interface

### Problem
- When the public IP changes, the Cloudflare DNS record does not update
- pfSense DDNS status turns red instead of green
- pfSense WAN interface uses a **private IP**, so changes do not trigger DDNS updates
- Result: occasional loss of remote access

### Solution
- Custom script to detect public IP changes
- Updates Cloudflare DNS record when a change is detected
- Works independently of pfSense WAN IP changes

❗ Script:  
[scripts/smb-vm-mount.sh](11-Scripts/pfsense/ddns-force-update.sh)

---

← [Back to Homelab main page](../README_HU.md)
