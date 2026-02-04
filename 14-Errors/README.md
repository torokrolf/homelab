← [Back to Homelab Main Page](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Errors & Troubleshooting

## 📚 Table of Contents

- [DNS – Public domain resolution without internet](#dns--public-domain-resolution-without-internet)
- [DNS – Pi-hole blocking Google Image search results on mobile](#dns--pi-hole-blocking-google-image-search-results-on-mobile)
- [SSH – SSH login for LXC / Ubuntu](#ssh--ssh-login-for-lxc--ubuntu)
- [Sharing – SMB/NFS access from LXC](#sharing--smbnfs-access-from-lxc)
- [Hardware – External SSD stability over USB](#hardware--external-ssd-stability-over-usb--via-tp-link-ue330-vs-direct-connection)
- [Hardware – M70q internal network adapter instability](#hardware--m70q-internal-network-adapter-instability--solution-with-external-usb-adapter)
- [Hardware – Local and public DNS issues due to laptop Wi-Fi adapter](#hardware--local-and-public-dns-issues-due-to-laptop-wi-fi-adapter)
- [DDNS – DDNS not updating on Cloudflare behind pfSense](#ddns--ddns-not-updating-on-cloudflare-behind-pfsense)

---

## DNS - Public domain resolution without internet

**Problem**:
- The `*.trkrolf.com` (e.g., `zabbix.trkrolf.com`) is a public domain pointed to Cloudflare nameservers, which returned the local Nginx IP (192.168.2.202).
- If the homelab **lost internet connection**, the name would not resolve because the public DNS was unreachable.

**Solution**:
- **DNS override / Local BIND9 DNS**: Queries for `*.trkrolf.com` are handled by the local DNS server.
- This ensures the domain always resolves to the **local Nginx IP (192.168.2.202)** even without an active internet connection.

---

## DNS - Pi-hole blocking Google Image search results on mobile

**Problem**:
- When clicking on **Google Image search results** on mobile devices:
  - The page often fails to open.
  - Or the image does not redirect to the source website.
- This issue occurs rarely or not at all on desktop computers.

**Root Cause**:
- On mobile, Google Image results do not point directly to image files, but instead route through:
  - Advertising domains
  - Tracking domains
  - Redirect domains
- These domains (e.g., `googleadservices.com`, `googletagservices.com`, `doubleclick.net`) are frequently included in **Pi-hole blocklists**.
- Some image delivery/CDN domains (like subdomains of `gstatic.com`) might also be blocked.

**Note**:
- This behavior is **not a Pi-hole bug**, but a natural consequence of aggressive ad and tracker blocking.

**My Solution**:
- Temporarily disable Pi-hole when needed (e.g., via a script triggered from mobile over SSH).

**Alternative Solution (Not recommended)**:
- Targeted whitelisting (not recommended for everyone as ads will reappear).

❗ Script implementation: [scripts/smb-vm-mount.sh](/11-Scripts/Android/toggle_pihole_ssh.sh)

---

## SSH - SSH login for LXC / Ubuntu

**Problem**:
- LXC containers often only have a root user, and SSH login for root is disabled by default.

**Recommended Solution**:
- Create a regular user.
- Enable SSH login using a password or (preferably) an SSH key.

**Non-recommended Solution**:
- Enabling root SSH login (`PermitRootLogin yes`) in the SSH configuration.

---

## Sharing – SMB/NFS access from LXC

**Problem**:
- Unprivileged LXC containers cannot mount network shares directly.

**Solution**:
- Mount the share on the **Proxmox host**. I tried systemd and fstab, but both caused the `df` command to hang on the host if the share was unavailable. **AutoFS** solved this; while it may still hang briefly, it times out after 1 minute and allows `df` to function normally.
- Pass the mounted directory to the LXC container using a **bind mount** (`mp0:`).
- Ensure correct permissions (uid/gid mapping, file_mode/dir_mode) so the share remains writable inside the container.

**Security**:
- While Privileged LXC containers can mount SMB shares directly, the container's root is identical to the Proxmox host's root → **Security Risk**.
- **Unprivileged LXC + Host Mount** is the secure and functional solution, as the container's root is mapped to a non-privileged user on the host.

---

## Hardware - External SSD stability over USB — via TP-Link UE330 vs. Direct connection

**Problem**:
- A **Samsung 870 EVO** external SSD occasionally **disconnected** when plugged directly into the host's USB port.

**Solution**:
- Connecting the SSD through a **TP-Link USB hub (UE330)** resulted in **stable operation** for over 6 months.
- This is likely due to the more stable power delivery provided by the TP-Link UE330.

---

## Hardware - M70q internal network adapter instability — Solution with external USB adapter (TP-Link UE330)

**Problem**:
- The internal network adapter on the M70q occasionally loses connection, requiring physical access to the machine to reset the interface.

**Potential Solution**:
- A watchdog script that pings the router and restarts the network interface if the ping fails.

**Chosen Solution**:
- Using a **TP-Link UE330 USB network adapter**: It has proven to be perfectly stable, with over 6 months of uninterrupted uptime.

---

## Hardware - Local and public DNS issues due to laptop Wi-Fi adapter

### Problem
- Local DNS occasionally failed to resolve local hostnames or even public ones (e.g., google.com).
- The network adapter was a **MediaTek 7921**, which is known for unstable DNS handling under Linux.

### Solution
- Replaced the MediaTek 7921 with an **Intel AX210** adapter.
- DNS resolution is now stable for both local and public queries.

---

## DDNS - DDNS not updating on Cloudflare behind pfSense (Private WAN IP issue)

### Problem
- When the public IP changes, the Cloudflare record does not update automatically.
- The pfSense DDNS status turned red (error) instead of the green checkmark.
- This happened because the pfSense WAN interface is behind another router (CGNAT/Double NAT) and has a **private IP**, so pfSense doesn't "see" the public IP change to trigger the update.

### Solution
- Created a custom script that checks the actual public IP and forces a Cloudflare update upon detecting a change.
- This ensures the record is updated based on the actual public IP rather than the local WAN interface IP.

❗ Script implementation: [11-Scripts/pfsense/ddns-force-update.sh](11-Scripts/pfsense/ddns-force-update.sh)

---

← [Back to Homelab Main Page](../README.md)
