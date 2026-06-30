← [Back to Homelab main page](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Errors

## 📚 Table of Contents

- [DNS – Public domain name resolution without internet](#dns-offline)
- [DNS – Pi-hole blocking Google image search results](#dns-pihole)
- [DNS – ARP starving caused by AdGuard DNS rate limit](#ratelimit)
- [SSH – SSH login on LXC / Ubuntu](#ssh-lxc)
- [Mounts – SMB/NFS access from LXC](#mount-lxc)
- [Mounts – when the TrueNAS share is unavailable](#nemelerheto)
- [Hardware – External SSD stability over USB](#hw-ssd)
- [Hardware – M70q network adapter instability](#hw-m70q)
- [Hardware – Local and public DNS issues (Wi-Fi)](#hw-wifi)
- [DDNS – Cloudflare update behind pfSense](#ddns-pfsense)
- [Apt-cacher-ng stuck packages](#aptcacherng)
- [AWS – DNS override conflict (BIND9 wildcard vs EC2 subdomain)](#dns-override-aws)
- [AWS – Cloudflare wildcard certificate limit](#cf-wildcard-limit)

---

## DNS – Public domain name resolution without internet
<a name="dns-offline"></a>

**Problem**:
- Accessing the `*.trkrolf.com` public domain failed without an internet connection.

**Solution**:
- **DNS override**: the wildcarded trkrolf.com (`*.trkrolf.com`) records resolve directly to Traefik's local IP on the internal network, bypassing the external lookup.

---

## DNS – Pi-hole blocking Google image search results on mobile
<a name="dns-pihole"></a>

**Problem**:
- On mobile, Google image search results wouldn't open because of Pi-hole's blocklists.

**Cause**:
- Google uses tracking domains (e.g. `googleadservices.com`) that are present on the blocklists.

**Solution**:
- Temporarily disabling Pi-hole via an SSH script.

❗ Script: [/11-Scripts/Android/toggle_pihole_ssh.sh](/11-Scripts/Android/toggle_pihole_ssh.sh)

---

## DNS – ARP starving caused by AdGuard DNS rate limit
<a name="ratelimit"></a>

**Problem description**
After switching from Pi-hole to AdGuard Home, the Proxmox hosts (192.168.2.198, 192.168.2.199) became unreachable from the 192.168.1.0/24 network. Interestingly, the VMs and LXC containers running on those hosts remained pingable, but the physical nodes themselves stopped responding.

**Cause**

- **DNS rate limit:** AdGuard Home's default rate limit (**20 queries/sec**) was too low. Clients exceeded it, and AdGuard Home started dropping requests.
- **DNS Flood:** Due to the failed resolutions, clients began aggressively retrying, increasingly often, which overloaded the Proxmox network interface — a self-reinforcing process.
- **Missing records:** Since the Proxmox nodes had fixed IPs (not assigned via pfSense DHCP), they didn't have a static ARP entry enabled on pfSense. Because of the network noise, they couldn't get into the ARP table, resulting in **ARP starving**.
- **ARP starving:** Due to the large number of dropped packets and the resulting queue, the Proxmox interface couldn't respond in time to pfSense's ARP requests, which are needed for PING. The VMs and LXC containers on the Proxmox node remained pingable from the 1.0 network because they received their IP from the pfSense DHCP server, which also assigned them static ARP entries (since I had configured that). So their IP + MAC address pairing was already known.

**Solution**

1. **Pinning static ARP:**
    * Added the Proxmox hosts to the **DHCP Static Mappings** list in pfSense.
    * After locking in the MAC addresses, enabled the **Static ARP** option, so the router no longer needs to look up the hosts via ARP requests.
2. **Raising the AdGuard Home limit:**
    * In the AdGuard interface: Settings / DNS settings / Rate limit.

---

## SSH – SSH login on LXC / Ubuntu
<a name="ssh-lxc"></a>

**Problem**:
- Root SSH login is disabled by default inside LXC containers.

**Solution**:
- Creating a regular user and setting up SSH key-based authentication.

---

## Mounts – SMB/NFS access from LXC
<a name="mount-lxc"></a>

**Problem**:
- Unprivileged LXC containers can't directly mount network shares.

**Solution**:
- Forwarding the share — already mounted on the Proxmox host via **AutoFS** — into the container using a bind mount (`mp0`).
- This also prevents the `df` command from hanging if the storage becomes unavailable.

---

## Mounts – when the TrueNAS share is unavailable
<a name="nemelerheto"></a>

**Problem**:
- Since several VMs and LXC containers on Proxmox1 use the TrueNAS share, it's a real concern what happens if that share becomes unavailable. For example, when the share dropped out, qBittorrent simply kept downloading onto the VM's local storage instead — which is a problem.

**Solution**:
The best approach I found is to stop the affected LXC and VM machines whenever the share is unavailable — since I follow a one-service-per-VM/LXC principle, this doesn't affect any other running service. Once the share becomes available again, the VM/LXC is started back up.
- All shares are mounted on the Proxmox host via fstab, so it can check and forward them to LXC containers.
- A script checks every 30 seconds whether the share is reachable.
- If the share is reachable, it checks whether the VM/LXC is running, and starts it if not.
- If the share is unreachable, it stops the VM/LXC if it's running.

❗ Script: [/11-Scripts/Android/proxmox-mount-monitor.sh](/11-Scripts/proxmox/mount-monitor)

The image below shows that when I stop TrueNAS, the affected VM/LXC machines on the other Proxmox node stop as well. Starting TrueNAS back up brings those machines back up too.
<p align="center">
  <img src="https://github.com/user-attachments/assets/042abb72-ea53-4769-b017-237a0f493dbe" alt="TrueNAS stopped" width="400">
</p>

---

## Hardware – External SSD stability over USB
<a name="hw-ssd"></a>

**Problem**:
- The Samsung 870 EVO SSD was unstable when connected directly via USB.

**Solution**:
- Using a TP-Link UE330 USB hub, which provides more stable power delivery.

---

## Hardware – M70q network adapter instability
<a name="hw-m70q"></a>

**Problem**:
- The M70q's built-in network card randomly dropped the connection.

**Solution**:
- Using a TP-Link UE330 external USB adapter for stable network access.

---

## Hardware – Local and public DNS issues due to Wi-Fi adapter
<a name="hw-wifi"></a>

**Problem**:
- The MediaTek 7921 Wi-Fi card produced unstable DNS resolution on Linux.

**Solution**:
- Replacing the adapter with an Intel AX210.

---

## DDNS – pfSense DDNS not updating Cloudflare behind double NAT
<a name="ddns-pfsense"></a>

**Problem**

The pfSense WAN interface doesn't have a **public IP**, but a **static private IP (e.g. 192.168.1.196)**, since the router sits behind double NAT.

pfSense's built-in Dynamic DNS mechanism (`/etc/rc.dyndns.update`) is triggered in 3 cases:

- system boot
- the WAN interface receives a new IP
- the WAN interface goes down/up

Since the IP on the WAN interface never actually changes, pfSense **doesn't notice** that the real public IP on the upstream router has changed, and so it never updates the Cloudflare DNS record.

The result: the trkrolf.com domain becomes unreachable from outside.

**Solution**

A script forces pfSense to react to changes in the **actual public IP**, rather than to changes on the WAN interface.

The mechanism:

- Queries the current public IP via checkip.amazonaws.com
- Compares it against the previously stored IP, kept in a file
- If it changed:
   - updates the stored IP in the file
   - manually invokes the `/etc/rc.dyndns.update` script

This way, the Cloudflare record always points to the correct public IP.

❗ Script: [/11-Scripts/pfsense/ddns-force-update.sh](/11-Scripts/pfsense/ddns-force-update.sh)

---

## Apt-cacher-ng stuck packages issue

<a name="aptcacherng"></a>

**Problem**
During Ansible-driven client updates, I noticed in the Semaphore GUI that runs would sometimes not complete — they'd just hang and wait indefinitely. This is visible in the image below.
<p align="center">
  <img src="https://github.com/user-attachments/assets/db0a18b6-dd7c-45b4-83cc-b9f97840c7f8" alt="Description" width="600">
</p>

**Cause**

- On the proxy server: `tail -f /var/log/apt-cacher-ng/apt-cacher.err` shows the cache errors, visible in the image below.
- The client requests the package from the proxy server (apt-cacher-ng).
- apt-cacher-ng's database sees that the downloaded package's file size doesn't match what its database says the file should officially be (`checked size beyond EOF`).
- The proxy tries to re-download the broken file, but can't, since a file by that name already exists (`file exists`) — even though it's corrupted — so the client **waits for the package indefinitely**.
<p align="center">
  <img src="https://github.com/user-attachments/assets/3563cca6-e744-4dbe-b23f-4ae2823db9ac" alt="Description" width="600">
</p>

**Solution**

The `acngtool` maintenance command was added to cron, running every day at 22:30. This automatically cleans and rebuilds the cache, preventing it from getting stuck — running right before the 23:00 Ansible-driven update playbook, thereby avoiding the hang.

```
30 22 * * * /usr/lib/apt-cacher-ng/acngtool maint -c /etc/apt-cacher-ng >/dev/null 2>&1
```

---

## AWS – DNS override conflict (BIND9 wildcard vs EC2 subdomain)
<a name="dns-override-aws"></a>

**Problem**:
- The EC2 services wouldn't load on the home network, but worked fine on mobile data.

**Cause**:
- The homelab's BIND9 has a `*.trkrolf.com` wildcard override that routes everything to the local Traefik instance, so the EC2 subdomains never even reached Cloudflare.

<img width="691" height="255" alt="image" src="https://github.com/user-attachments/assets/b55f6d2a-6a33-40c0-b048-38c288e24153" />

**Solution**:
- Creating an exception in AdGuard Home for the EC2 subdomains, so they don't get routed to the overridden BIND9 record, but instead resolve to the Cloudflare proxy IP.

Finding out the Cloudflare proxy IP:

```bash
nslookup gotifyaws.trkrolf.com 1.1.1.1
ipconfig /flushdns
```

<img width="726" height="379" alt="image" src="https://github.com/user-attachments/assets/df18226d-62c7-428f-9510-0b144f2ac834" />

The AdGuard override shown here.

<img width="945" height="430" alt="image" src="https://github.com/user-attachments/assets/f5d775b8-ba9e-4cc4-b31e-45ea16fe90d3" />

---

## AWS – Cloudflare wildcard certificate limit
<a name="cf-wildcard-limit"></a>

**Problem**:
- `uptime.aws.trkrolf.com` — SSL Handshake Failure; reachable over HTTP but not HTTPS.

**Cause**:
- Cloudflare Universal SSL (the free tier) only covers a single-level wildcard (`*.trkrolf.com`). `uptime.aws.trkrolf.com` is a third-level subdomain, so it falls outside that scope.

**Solution**:
- Renaming the subdomains to single-level in the Cloudflare tunnel: `uptimeaws.trkrolf.com`, `gotifyaws.trkrolf.com` — these are already covered by the `*.trkrolf.com` wildcard.

<img width="1603" height="415" alt="image" src="https://github.com/user-attachments/assets/078d4589-e97a-451f-9324-f4e315711493" />

> **Important takeaway:** on the Cloudflare free tier, always plan for single-level subdomains if you're relying on a wildcard cert — otherwise you'd need Total TLS, which is a paid feature.

---

← [Back to Homelab main page](../README.md)
