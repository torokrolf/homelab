← [Back to Homelab Main Page](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Errors

## 📚 Table of Contents

- [DNS – Public domain resolution without internet](#dns-offline)
- [DNS – Pi-hole blocking Google Image search results](#dns-pihole)
- [DNS – ARP starving caused by AdGuard DNS rate limit](#ratelimit)
- [SSH – SSH login issues with LXC / Ubuntu](#ssh-lxc)
- [Sharing – SMB/NFS access from LXC](#mount-lxc)
- [Sharing – Handling TrueNAS share unavailability](#unavailable)
- [Hardware – External SSD stability over USB](#hw-ssd)
- [Hardware – M70q network adapter instability](#hw-m70q)
- [Hardware – Local and public DNS issues (Wi-Fi)](#hw-wifi)
- [DDNS – Cloudflare update behind pfSense](#ddns-pfsense)
- [Apt-cacher-ng csomagok beragadása](#aptcacherng)

---

## DNS – Public domain resolution without internet
<a name="dns-offline"></a>

**Problem**:
- Accessing the `*.trkrolf.com` public domain failed when the internet connection was down.

**Solution**:
- **DNS override**: Implemented a wildcard DNS override for `*.trkrolf.com` in the local resolver. This ensures requests resolve directly to the local Traefik IP, bypassing external lookups.

---

## DNS – Pi-hole blocking Google Image search results on mobile
<a name="dns-pihole"></a>

**Problem**:
- Google Image search results fail to open on mobile devices due to Pi-hole blocking lists.

**Cause**:
- Google uses tracking domains (e.g., `googleadservices.com`) for certain results, which are present on standard blocklists.

**Solution**:
- Created an SSH script to temporarily disable Pi-hole when needed.

❗ Script: [/11-Scripts/Android/toggle_pihole_ssh.sh](/11-Scripts/Android/toggle_pihole_ssh.sh)

---

## DNS – ARP starving caused by AdGuard DNS rate limit
<a name="ratelimit"></a>

**Problem Description**:
After migrating from Pi-hole to AdGuard Home (AGH), Proxmox hosts (`192.168.2.198`, `192.168.2.199`) became unreachable from the `192.168.1.0/24` network. Interestingly, the VMs and LXC containers running on these hosts remained pingable, but the physical nodes themselves did not respond.

**Cause**:
- **DNS rate limit:** AdGuard Home's default rate limit (**20 queries/sec**) was too low. Clients exceeded this limit, causing AdGuard Home to drop requests.
- **DNS Flood:** Due to failed resolutions, clients initiated aggressive DNS retries. This created a self-reinforcing loop that saturated the Proxmox network interface.
- **Missing records:** Since the Proxmox nodes had fixed IPs (configured on the host, not by pfSense DHCP), **Static ARP** was not enabled for them in pfSense. Due to network noise, they could not be added to the ARP table, resulting in **ARP starvation**.
- **ARP starvation:** Due to the high volume of dropped packets and queuing, the Proxmox interface could not respond to pfSense's ARP requests (required for PING) in time. The VMs and LXCs on the Proxmox node remained pingable from `1.0` because they received their IPs from the pfSense DHCP server, where Static ARP was already configured and enabled. Thus, their IP + MAC address pairs were already known.

**Solution**:
1. **Static ARP Binding:**
   - Added Proxmox hosts to the **DHCP Static Mappings** in pfSense.
   - Enabled the **Static ARP** option for these mappings. This ensures the router has a hardcoded MAC-IP pairing and doesn't need to broadcast ARP requests.
2. **Remove AdGuard Rate Limit:**
   - Navigation: `Settings` -> `DNS settings` -> `Rate limit`.
   - Set the value to **0** (disabled) or a significantly higher threshold.

---

## SSH – SSH login for LXC / Ubuntu
<a name="ssh-lxc"></a>

**Problem**:
- Root SSH login is disabled by default in LXC containers.

**Solution**:
- Create a regular user and configure SSH key-based authentication.

---

## Sharing – SMB/NFS access from LXC
<a name="mount-lxc"></a>

**Problem**:
- Unprivileged LXC containers cannot mount network shares directly.

**Solution**:
- Use **AutoFS** on the Proxmox host to mount the shares, then pass them to the LXC using a bind mount (`mp0`).
- This prevents the `df` command from hanging if the storage goes offline.

---

## Sharing – Handling TrueNAS share unavailability
<a name="unavailable"></a>

**Problem**:
- Several VMs and LXCs on the Proxmox1 node depend on TrueNAS shares. If the share becomes unavailable, services like qBittorrent might continue downloading to the VM's local storage, filling up the disk.

**Solution**:
- Adopted a "shutdown on failure" policy. Since I follow the "one service per VM/LXC" principle, stopping affected machines doesn't impact other services.
- Proxmox uses **autofs** to mount and monitor shares.
- A script runs every 30 seconds to check share availability.
- If the share is online: The script starts the VM/LXC if it isn't running.
- If the share is offline: The script shuts down the affected VM/LXC immediately.

❗ Script: [/11-Scripts/proxmox/mount-monitor](/11-Scripts/proxmox/mount-monitor)

The image below shows that when TrueNAS is stopped, the dependent VMs/LXCs on the other Proxmox node shut down automatically. They restart once TrueNAS is back online.

<p align="center">
  <img src="https://github.com/user-attachments/assets/042abb72-ea53-4769-b017-237a0f493dbe" alt="TrueNAS stopped" width="400">
</p>

---

## Hardware – External SSD stability over USB
<a name="hw-ssd"></a>

**Problem**:
- Samsung 870 EVO SSD was unstable when connected directly via USB.

**Solution**:
- Using a powered TP-Link UE330 USB hub to provide stable power delivery.

---

## Hardware – M70q network adapter instability
<a name="hw-m70q"></a>

**Problem**:
- The internal network card of the M70q randomly dropped the connection.

**Solution**:
- Using a TP-Link UE330 external USB-to-Ethernet adapter for stable connectivity.

---

## Hardware – Local and public DNS issues due to Wi-Fi adapter
<a name="hw-wifi"></a>

**Problem**:
- The MediaTek 7921 Wi-Fi card produced unstable DNS resolution in Linux environments.

**Solution**:
- Replaced the adapter with an Intel AX210.

---

## DDNS – pfSense DDNS not updating Cloudflare behind Double NAT
<a name="ddns-pfsense"></a>

**Problem**

The pfSense WAN interface does **not have a public IP address**, but a **static private IP (e.g. 192.168.1.196)** because the router is located behind double NAT.

The built-in pfSense Dynamic DNS mechanism (`/etc/rc.dyndns.update`) is triggered only in three cases:

- system startup
- the WAN interface receives a new IP address
- the WAN interface is brought down and up again

Since the IP address on the WAN interface never changes, pfSense **does not detect** that the real public IP has changed on the upstream router, therefore it does not update the Cloudflare DNS record.

As a result, the `trkrolf.com` domain becomes unreachable from outside the network.

---

**Solution**

With the help of a script, we force pfSense to react **not to the WAN IP change**, but to the **actual public IP change**.

Mechanism:

- It queries the current public IP using `checkip.amazonaws.com`
- It compares it with the previously stored IP saved in a file
- If a change is detected:
  - it updates the stored IP in the file
  - it manually triggers the `/etc/rc.dyndns.update` script

This ensures that the Cloudflare record always points to the correct public IP.

❗ Script: [/11-Scripts/pfsense/ddns-force-update.sh](/11-Scripts/pfsense/ddns-force-update.sh)

---

## Apt-cacher-ng Stuck Package Issue
<a name="aptcacherng"></a>

**Problem**  
During client updates via Ansible, I noticed in the Semaphore GUI that sometimes the update does not complete—it gets stuck and waits indefinitely. This can be seen in the figure below:

<p align="center">
  <img src="https://github.com/user-attachments/assets/db0a18b6-dd7c-45b4-83cc-b9f97840c7f8" alt="Semaphore GUI" width="600">
</p>

**Cause**  

- On the proxy server: `tail -f /var/log/apt-cacher-ng/apt-cacher.err` shows cache errors, as illustrated below.  
- The client requests the package from the proxy server (`apt-cacher-ng`).  
- The apt-cacher-ng database detects that the downloaded package size does not match the expected size in the database (`checked size beyond EOF`).  
- The proxy tries to re-download the faulty file but cannot, because a file with the same name already exists (even if incorrect), so the client **waits for the package indefinitely**.

<p align="center">
  <img src="https://github.com/user-attachments/assets/3563cca6-e744-4dbe-b23f-4ae2823db9ac" alt="Proxy errors" width="600">
</p>

**Solution**  

The `acngtool` maintenance command is scheduled via cron to run **daily at 22:30**. This automatically cleans and rebuilds the cache, preventing stuck updates, and runs just before the **23:00 Ansible update playbook**, avoiding the issue entirely.

30 22 * * * /usr/lib/apt-cacher-ng/acngtool maint -c /etc/apt-cacher-ng >/dev/null 2>&1

---

← [Back to Homelab Main Page](../README.md)
