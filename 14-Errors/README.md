← [Back to the Homelab main page](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Errors

## 📚 Table of Contents

- [DNS – Public domain resolution without internet access](#dns-offline)
- [DNS – Pi-hole blocks Google image results on mobile](#dns-pihole)
- [DNS – AdGuard DNS rate limitből adótó ARP starving ](#ratelimit)
- [SSH – SSH login for LXC / Ubuntu](#ssh-lxc)
- [Mount – SMB/NFS access from LXC](#mount-lxc)
- [Mount – When the TrueNAS share is not reachable](#notreachable)
- [Hardware – External SSD stability over USB](#hw-ssd)
- [Hardware – M70q network adapter instability](#hw-m70q)
- [Hardware – Local and public DNS issues caused by Wi-Fi](#hw-wifi)
- [DDNS – Cloudflare update behind pfSense](#ddns-pfsense)

---

## DNS – Public domain resolution without internet access
<a name="dns-offline"></a>

**Problem**:
- Accessing the public `*.trkrolf.com` domain failed when there was no internet connection.

**Solution**:
- **DNS override / split-horizon DNS**: Wildcard `trkrolf.com` (`*.trkrolf.com`) records resolve directly to the internal Traefik IP inside the local network, bypassing any external DNS queries.

---

## DNS – Pi-hole blocks Google image results on mobile
<a name="dns-pihole"></a>

**Problem**:
- Google image results would not open on mobile devices due to Pi-hole blocklists.

**Cause**:
- Google uses tracking domains (e.g. `googleadservices.com`) which are present on blocklists.

**Solution**:
- Temporarily disabling Pi-hole using an SSH script.

❗ Script: [/11-Scripts/Android/toggle_pihole_ssh.sh](/11-Scripts/Android/toggle_pihole_ssh.sh)

---

## DNS – AdGuard DNS rate limitből adótó ARP starving
<a name="ratelimit"></a>

---

## SSH – SSH login for LXC / Ubuntu
<a name="ssh-lxc"></a>

**Problem**:
- Root SSH login is disabled by default in LXC containers.

**Solution**:
- Creating a regular user and configuring SSH key-based authentication.

---

## Mount – SMB/NFS access from LXC
<a name="mount-lxc"></a>

**Problem**:
- Unprivileged LXC containers cannot directly mount network shares.

**Solution**:
- Mounting the shares on the Proxmox host using **AutoFS**, then passing them to the container via bind mount (`mp0`).
- This also prevents the `df` command from hanging if the storage becomes unavailable.

---

## Mount – When the TrueNAS share is not reachable
<a name="notreachable"></a>

**Problem**:
- Several VMs and LXCs on Proxmox1 rely on TrueNAS shares. If the share becomes unavailable, services like qBittorrent continue downloading to the VM’s local disk, which causes issues.

**Solution**:
- The most reliable approach I found is to stop the affected VMs/LXCs when the share is unavailable. Since I follow the “one service per VM/LXC” principle, this does not impact other services.
- When the share becomes available again, the VMs/LXCs are automatically started.

Workflow:
- All shares are mounted on Proxmox using AutoFS so their availability can be checked.
- A script checks every 30 seconds whether the share is reachable.
- If the share is reachable, it checks whether the VM/LXC is running; if not, it starts it.
- If the share is not reachable, it stops the VM/LXC if it is running.

❗ Script: [/11-Scripts/proxmox/mount-monitor](/11-Scripts/proxmox/mount-monitor)

In the image below, when TrueNAS is stopped, the affected VMs/LXCs on the other Proxmox node are also stopped. When TrueNAS starts again, these machines automatically start as well.

<p align="center">
  <img src="https://github.com/user-attachments/assets/042abb72-ea53-4769-b017-237a0f493dbe" alt="TrueNAS stopped" width="400">
</p>

---

## Hardware – External SSD stability over USB
<a name="hw-ssd"></a>

**Problem**:
- The Samsung 870 EVO SSD was unstable when connected directly over USB.

**Solution**:
- Using a TP-Link UE330 USB hub, which provides more stable power delivery.

---

## Hardware – M70q network adapter instability
<a name="hw-m70q"></a>

**Problem**:
- The internal network adapter of the M70q randomly dropped connections.

**Solution**:
- Using a TP-Link UE330 external USB network adapter for stable connectivity.

---

## Hardware – Local and public DNS issues caused by Wi-Fi
<a name="hw-wifi"></a>

**Problem**:
- The MediaTek 7921 Wi-Fi card caused unstable DNS resolution under Linux.

**Solution**:
- Replacing the adapter with an Intel AX210.

---

## DDNS – Cloudflare update behind pfSense
<a name="ddns-pfsense"></a>

**Problem**:
- Because pfSense had a private WAN IP, DDNS could not detect public IP changes.

**Solution**:
- A custom script that checks the public IP externally and updates the Cloudflare record.

❗ Script: [/11-Scripts/pfsense/ddns-force-update.sh](/11-Scripts/pfsense/ddns-force-update.sh)

---

← [Back to the Homelab main page](../README_HU.md)
