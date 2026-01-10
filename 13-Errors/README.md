← [Back to Homelab Home](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Errors

## 📚 Table of Contents

- [DNS – Public domain resolution without internet](#dns--public-domain-resolution-without-internet)
- [DNS – Pi-hole blocking Google image results on mobile](#dns--pi-hole-blocking-google-image-results-on-mobile)
- [SSH – SSH login in LXC / Ubuntu](#ssh--ssh-login-in-lxc--ubuntu)
- [Share – SMB access from LXC](#share--smb-access-from-lxc)
- [Race condition – SMB mount order](#race-condition--smb-mount-order)
- [Share – Dynamic NFS mount for qBittorrent + race condition handling](#share--dynamic-nfs-mount-for-qbittorrent-with-race-condition-handling-and-stop-qbittorrent-if-share-disappears)
- [Hardware – External SSD stability via USB](#hardware--external-ssd-stability-usb--tp-link-ue330-vs-direct-usb)
- [Hardware – M70q network adapter instability](#hardware--m70q-internal-network-adapter-instability--solution-with-usb-adapter-tp-link-ue330)
- [Hardware – Local and public DNS issues due to Wi-Fi adapter](#hardware--local-and-public-dns-issues-due-to-my-laptop-wi-fi-adapter)
- [DDNS – DDNS not updating on Cloudflare due to PFSense WAN using private IP](#ddns--ddns-not-updating-on-cloudflare-due-to-pfsense-wan-interface-using-private-ip)

---

## DNS – Public domain resolution without internet

**Problem:**
- The `*.trkrolf.com` domains (e.g., `zabbix.trkrolf.com`) are public, pointing to Cloudflare nameservers, which resolved to the Nginx IP `192.168.2.202`.
- If the homelab had **no internet**, the domain would not resolve because the public DNS was unreachable.

**Solution:**
- **DNS override / local BIND9 DNS**: queries for `*.trkrolf.com` are handled by the local DNS server.
- The name always resolves to **192.168.2.202 Nginx IP** even without internet.

---

## DNS – Pi-hole blocking Google image results on mobile

**Problem**
- On mobile, clicking on Google image results often:
  - the page doesn’t open, or
  - the image does not redirect to the source website
- On desktop, this happens rarely or not at all.

**Cause**
- Google images on mobile do **not link directly to the image files**, but to:
  - advertising domains
  - tracking domains
  - redirecting domains
- These domains are often **blocked by Pi-hole**, e.g.:
  - `googleadservices.com`
  - `googletagservices.com`
  - `doubleclick.net`
- Clicking triggers a tracking redirect link, blocked at DNS level by Pi-hole.
- Some CDN/image domains (e.g., `*.gstatic.com`) may also be blocked.

**Note**
- This is **not a Pi-hole bug**, but a natural consequence of ad/tracking blocking.
- The above domains are intentionally blocked in default or community blocklists.

**Solution I use**
- Temporarily disable Pi-hole (e.g., via SSH script on mobile).

**Alternative, not recommended**
- Whitelist domains selectively (may re-enable ads, so not preferred).

❗Script implementation: [scripts/smb-vm-mount.sh](/11-Scripts/Android/toggle_pihole_ssh.sh)

---

## SSH – SSH login in LXC / Ubuntu

**Problem:**
- Only root exists in the LXC, SSH login as root is disabled.

**Recommended solution:**
- Create a regular user
- Enable SSH login via password or SSH key

**Not recommended:**
- Enable root SSH login (`PermitRootLogin yes`)
- SSH login via password or key

---

## Share – SMB access from LXC

**Problem:**
- Unprivileged LXC containers cannot mount SMB/CIFS shares directly.

**Solution:**
- Mount the SMB/CIFS share on the Proxmox host
- Bind mount the directory to the LXC (`mp0:`)
- Ensure proper permissions (uid/gid, file_mode/dir_mode) for write access inside LXC

**Security**
- Privileged LXC can mount SMB directly, but container root = host root → **security risk**  
- Unprivileged LXC + host mount → secure and functional: container root has limited rights, cannot perform dangerous operations on Proxmox host.

---

## Race condition – SMB mount order

**Problem:**  
- Proxmox tried to mount an SMB share from a VM during boot  
- The VM was not running yet, causing the mount to fail due to a race condition  

**Why systemd service is better than fstab:**  
- Network shares (NFS/CIFS) may fail if the network is not ready.  
- fstab mount at boot may not succeed if the network is down; boot usually continues but is not ideal.  
- External SSD/HDD via fstab works fine, no race condition.  
- For network shares, **systemd waits for network & share availability**, then mounts once.

**Correct sequence:**
1. Proxmox host boots  
2. systemd service activates  
3. Service pings the VM (ExecStartPre)  
4. If VM reachable → run mount script (ExecStart)  
5. Script checks SMB port (445), mounts only when available  
6. Mount successful → LXC can access share  

**Solution:**
- systemd service only pings VM availability
- mount script checks SMB port and mounts once available
- race condition eliminated

❗Script: [scripts/smb-vm-mount.sh](/11-Scripts/proxmox/smb-vm-mount.sh)  
❗Systemd service: [scripts/smb-vm-mount.service](/11-Scripts/proxmox/smb-vm-mount.service)

---

## Share – Dynamic NFS mount for qBittorrent with race condition handling and stop qBittorrent if share disappears

**Important:** Originally used SMB. With TrueNAS, qBittorrent started, but if TrueNAS stopped, qBittorrent didn’t stop properly; SMB did not handle unexpected disconnects well, and `df` froze. Using native NFS on Linux solved the issue completely.

**Problem:**
- At client boot (Ubuntu/Proxmox), systemd starts services  
- If qBittorrent starts before TrueNAS share mounts, errors occur or local drive may be used  
- Similar issue if TrueNAS shuts down or restarts unexpectedly

**Solution:**
- A background daemon script checks storage availability every 30s:
  - If NAS available: mounts NFS and starts qBittorrent
  - If NAS unavailable: stops qBittorrent and cleanly unmounts

**Implementation:**
- Infinite loop script monitors NAS
- If reachable:
  - Mount NFS
  - Start qBittorrent if not running
- If no

