← [Back to Homelab Main Page](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Errors & Troubleshooting

## 📚 Table of Contents

- [1.1 DNS – Public domain resolution without internet](#dns-offline)
- [1.2 DNS – Pi-hole blocking Google Image results](#dns-pihole)
- [1.3 SSH – SSH login for LXC / Ubuntu](#ssh-lxc)
- [1.4 Sharing – SMB/NFS access from LXC](#mount-lxc)
- [1.5 Sharing – Handling unavailable TrueNAS shares](#unavailable-share)
- [1.6 Hardware – External SSD stability over USB](#hw-ssd)
- [1.7 Hardware – M70q network adapter instability](#hw-m70q)
- [1.8 Hardware – Local and public DNS issues (Wi-Fi)](#hw-wifi)
- [1.9 DDNS – Cloudflare update behind pfSense](#ddns-pfsense)

---

## 1.1 DNS – Public domain resolution without internet
<a name="dns-offline"></a>

**Problem**:
- Access to the `*.trkrolf.com` public domain failed when the internet connection was down.

**Solution**:
- Implemented a local BIND9 DNS with a DNS override, ensuring the domain always resolves to the internal IP (192.168.2.202) even without an external connection.

---

## 1.2 DNS – Pi-hole blocking Google Image search results on mobile
<a name="dns-pihole"></a>

**Problem**:
- On mobile devices, Google Image results fail to open due to Pi-hole blocklists.

**Cause**:
- Google uses tracking and redirect domains (e.g., `googleadservices.com`) that are included in most common blocklists.

**Solution**:
- Temporarily disabling Pi-hole using an SSH script when needed.

❗ Script: [/11-Scripts/Android/toggle_pihole_ssh.sh](/11-Scripts/Android/toggle_pihole_ssh.sh)

---

## 1.3 SSH – SSH login for LXC / Ubuntu
<a name="ssh-lxc"></a>

**Problem**:
- Root SSH login is disabled by default in LXC containers.

**Solution**:
- Created a regular user and configured SSH key-based authentication.

---

## 1.4 Sharing – SMB/NFS access from LXC
<a name="mount-lxc"></a>

**Problem**:
- Unprivileged LXC containers cannot mount network shares directly.

**Solution**:
- Mounted the shares on the Proxmox host using **AutoFS** and passed them to the LXC via bind mounts (`mp0`).
- This prevents the `df` command from hanging if the storage server is offline.

---

## 1.5 Sharing – Handling unavailable TrueNAS shares
<a name="unavailable-share"></a>

**Problem**:
- Several VMs and LXCs on the Proxmox1 node rely on TrueNAS shares. If a share becomes unavailable, applications like qBittorrent might start downloading to the VM's local storage instead, which is undesirable.

**Solution**:
The best approach was to stop the affected LXC/VM units. Since I follow the "one service per VM/LXC" principle, this does not affect other services. If the share becomes available again, the script restarts the VM/LXC.
- All shares are mounted on Proxmox using autofs, so it can check them and pass them through to the LXC
- A script checks the availability of the mount every 30 seconds.
- If the share is available: It ensures the VM/LXC is running; if not, it starts it.
- If the share is unavailable: It stops the VM/LXC if it is currently running.

❗ Script: [/11-Scripts/Android/proxmox-mount-monitor.sh](/11-Scripts/proxmox/mount-monitor)

The image below shows that when TrueNAS is stopped, the affected VM/LXC machines on the other Proxmox node are also shut down. When TrueNAS is restarted, these machines will start up as well.

<p align="center">
  <img src="https://github.com/user-attachments/assets/042abb72-ea53-4769-b017-237a0f493dbe" alt="TrueNAS stopped" width="400">
</p>

---

## 1.6 Hardware – External SSD stability over USB
<a name="hw-ssd"></a>

**Problem**:
- The Samsung 870 EVO SSD was unstable when connected directly to the host's USB port.

**Solution**:
- Used a TP-Link UE330 USB hub, which provides more stable power delivery.

---

## 1.7 Hardware – M70q network adapter instability
<a name="hw-m70q"></a>

**Problem**:
- The internal network card of the M70q occasionally dropped the connection.

**Solution**:
- Switched to a TP-Link UE330 external USB adapter for stable network access.

---

## 1.8 Hardware – Local and public DNS issues due to Wi-Fi adapter
<a name="hw-wifi"></a>

**Problem**:
- The MediaTek 7921 Wi-Fi card produced unstable DNS resolution in Linux environments.

**Solution**:
- Replaced the adapter with an Intel AX210.

---

## 1.9 DDNS – DDNS not updating on Cloudflare behind pfSense
<a name="ddns-pfsense"></a>

**Problem**:
- Due to the private WAN IP on pfSense, the DDNS service did not detect changes in the public IP.

**Solution**:
- Used a custom script that checks the public IP externally and updates the Cloudflare record accordingly.

❗ Script: [/11-Scripts/pfsense/ddns-force-update.sh](/11-Scripts/pfsense/ddns-force-update.sh)

---

← [Back to Homelab Main Page](../README.md)
