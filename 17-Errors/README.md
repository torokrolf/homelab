← [Back to Homelab main page](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Errors

## 📚 Table of Contents

- [DNS – Public domain resolution without internet](#dns-offline)
- [DNS – Pi-hole blocking Google image search](#dns-pihole)
- [DNS – ARP starving caused by AdGuard DNS rate limit](#ratelimit)
- [SSH – SSH login on LXC / Ubuntu](#ssh-lxc)
- [Sharing – SMB/NFS access from LXC](#mount-lxc)
- [Sharing – when the TrueNAS share is unavailable](#nemelerheto)
- [Hardware – External SSD stability over USB](#hw-ssd)
- [Hardware – M70q network adapter instability](#hw-m70q)
- [Hardware – Local and public DNS issues (Wi-Fi)](#hw-wifi)
- [DDNS – Cloudflare update behind pfSense](#ddns-pfsense)
- [Apt-cacher-ng packages getting stuck](#aptcacherng)
- [AWS – DNS override conflict (BIND9 wildcard vs EC2 subdomain)](#dns-override-aws)
- [AWS – Cloudflare wildcard certificate limit](#cf-wildcard-limit)

---

## DNS – Public domain resolution without internet
<a name="dns-offline"></a>

**Problem**:
- Accessing the public domain `*.trkrolf.com` failed without an internet connection.

**Solution**:
- **DNS override**: Wildcard trkrolf.com (*.trkrolf.com) records resolve directly to the local Traefik IP on the internal network, bypassing external lookups.

---

## DNS – Pi-hole blocking Google image search on mobile
<a name="dns-pihole"></a>

**Problem**:
- On mobile, Google image search results wouldn't open due to Pi-hole's blocklists.

**Cause**:
- Google uses tracking domains (e.g. `googleadservices.com`) that are on the blocklists.

**Solution**:
- Temporary Pi-hole disable via an SSH script.

❗ Script: [/11-Scripts/Android/toggle_pihole_ssh.sh](/11-Scripts/Android/toggle_pihole_ssh.sh)

---

## DNS – ARP starving caused by AdGuard DNS rate limit
<a name="ratelimit"></a>

**Problem description**
After switching from Pi-hole to AdGuard Home, the Proxmox hosts (192.168.2.198, 192.168.2.199) became unreachable from the 192.168.1.0/24 network. Interestingly, the VMs and LXC containers running on those hosts remained pingable, but the physical nodes themselves stopped responding.

**Cause**

- **DNS rate limit:** AdGuard Home's default rate limit (**20 queries/sec**) was too low. Clients exceeded it, and AdGuard Home started dropping requests.
- **DNS Flood:** Due to failed resolutions, clients started retrying more and more aggressively, overloading the Proxmox network interface — a self-reinforcing process.
- **Missing records:** Since the Proxmox nodes had static IPs (not assigned via pfSense DHCP), there was no static ARP entry set up for them in pfSense. Because of the network noise, they couldn't get into the ARP table, resulting in **ARP starving**.
- **ARP starving:** Due to the large number of dropped packets and queuing, the Proxmox interface couldn't respond in time to pfSense's ARP requests, which are needed for PING. I could still ping the VMs and LXCs running on the Proxmox nodes because they received their IP from the pfSense DHCP server, where static ARP was also applied — since I had configured it. So their IP + MAC address pair was known.

**Solution**

1.  **Registering static ARP:**
    * In pfSense, I added the Proxmox hosts to the **DHCP Static Mappings** list.
    * After registering the MAC addresses, I enabled the **Static ARP** option, so the router no longer needs to search for the hosts via ARP requests.
2.  **Removing the AdGuard Home limit:**
    * In the AdGuard interface: Settings/DNS settings/Rate limit.

---

## SSH – SSH login on LXC / Ubuntu
<a name="ssh-lxc"></a>

**Problem**:
- Root SSH login is disabled by default in LXC containers.

**Solution**:
- Creating a regular user and setting up SSH key-based authentication.

---

## Sharing – SMB/NFS access from LXC
<a name="mount-lxc"></a>

**Problem**:
- Unprivileged LXC containers can't directly mount network shares.

**Solution**:
- The share is mounted on the Proxmox host via **AutoFS** and passed through using a bind mount (`mp0`).
- This avoids the `df` command hanging if the storage becomes unavailable.

---

## Sharing – when the TrueNAS share is unavailable
<a name="nemelerheto"></a>

**Problem**:
- Since several VMs and LXCs on my Proxmox1 node use the TrueNAS share, it can become a problem if the share becomes unavailable. For example, if the share was unavailable, qBittorrent continued the download using the VM's local storage instead, which is a problem.

**Solution**:
The best solution I found is to stop the LXC and VM machines in that case — since I follow a one-service-per-VM/LXC principle anyway, this doesn't affect any other service running. Once the share becomes available again, I start the VM/LXC back up.
- Every share is mounted on Proxmox via fstab, so it can check and pass it through to the LXCs.
- A script checks every 30 seconds whether the share is available.
- If the share is available, it checks whether the VM/LXC is running, and starts it if not.
- If the share is not available, it stops the VM/LXC if it's running.

❗ Script: [/11-Scripts/Android/proxmox-mount-monitor.sh](/11-Scripts/proxmox/mount-monitor)

The image below shows that when I stopped TrueNAS, the affected VM/LXC machines on the other Proxmox node also stopped. If I restarted TrueNAS, these machines would start back up too.
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
- The M70q's built-in network card (`eno2`, Intel e1000e) would randomly disconnect from the LAN, and often only came back after a reboot.

**Diagnostics**:
- Whenever the connection dropped, I sat down at the Proxmox host and ran the following command to check what happened at the driver level:
```bash
dmesg | grep eno2
```
- Based on the log, it pointed to e1000e driver errors/resets, suggesting the instability was not software-related (e.g. DHCP, cabling) but rather driver/hardware-level.

<img width="738" height="247" alt="kép" src="https://github.com/user-attachments/assets/6206a66c-c54c-4302-b9cb-e42b7141fc4b" />

**Solution attempts**

**Attempt 1 – Tuning e1000e driver parameters (didn't work)**

   I created the file, since it didn't exist yet:
```bash
   sudo nano /etc/modprobe.d/e1000e.conf
```
   Contents:

options e1000e InterruptThrottleRate=2000
options e1000e TxIntDelay=16
options e1000e RxIntDelay=16
options e1000e InterruptModeration=1
options e1000e FlowControl=1

Then rebooted. This setting alone did not fix the random disconnects.

**Attempt 2 – Watchdog script to automatically restart the interface (probably a good direction, but wasn't run long enough to confirm it was actually stable)**

   The idea here is essentially creating a custom WDT (watchdog timer): the script regularly pings a reachable device (e.g. the router), and if it fails, it brings the `eno2` interface down and back up.

```bash
   sudo nano /usr/local/bin/monitor_eno2.sh
```
```bash
   #!/bin/bash

   # Interface name
   INTERFACE="eno2"
   PING_TARGET="192.168.1.1"  # IP of the router or another reachable device

   # Check whether the interface responds (ping)
   if ! ping -c 1 -W 1 $PING_TARGET > /dev/null 2>&1; then
       echo "Network interface $INTERFACE is down. Restarting..."
       # If it doesn't respond, restart the interface
       ifdown $INTERFACE && ifup $INTERFACE
   fi
```
```bash
   sudo chmod +x /usr/local/bin/monitor_eno2.sh
```

   A systemd service was also created for this, so it runs continuously and restarts itself automatically if it stops:
```bash
   sudo nano /etc/systemd/system/network-watchdog.service
```
```ini
   [Unit]
   Description=Network Interface Watchdog for eno2
   After=network.target

   [Service]
   Type=simple
   ExecStart=/usr/local/bin/monitor_eno2.sh
   Restart=always
   RestartSec=30

   [Install]
   WantedBy=multi-user.target
```
```bash
   sudo systemctl daemon-reload
   sudo systemctl enable network-watchdog.service
   sudo systemctl start network-watchdog.service
   sudo systemctl status network-watchdog.service
```

**Final solution**:
- Instead of driver-level tuning and the watchdog script, using a **TP-Link UE330 external USB Ethernet adapter** ended up permanently solving the problem — it has been running flawlessly without any drops ever since.

---

## Hardware – Local and public DNS issues due to Wi-Fi adapter
<a name="hw-wifi"></a>

**Problem**:
- The MediaTek 7921 Wi-Fi card produced unstable DNS resolution on Linux.

**Solution**:
- Replacing the adapter with an Intel AX210.

---

## DDNS – pfSense DDNS not updating Cloudflare behind Double NAT
<a name="ddns-pfsense"></a>

**Problem**

The pfSense WAN interface does not have a **public IP address**, but rather a **static private IP (e.g. 192.168.1.196)**, because the router sits behind double NAT.

pfSense's built-in Dynamic DNS mechanism (/etc/rc.dyndns.update) is triggered in 3 cases:

- on system boot
- when the WAN interface receives a new IP
- when the WAN interface goes down/up

Since the IP on the WAN interface doesn't change, pfSense **doesn't detect** that the actual public IP on the upstream router has changed, so it doesn't update the Cloudflare DNS record.

The result: the trkrolf.com domain becomes unreachable from outside.

**Solution**

A script forces pfSense to react not to a **WAN IP change**, but to an **actual public IP change**.

The mechanism:

- Queries the current public IP via checkip.amazonaws.com
- Compares it to the previously stored IP, which is written to a file
- If there's a change:
   - updates the stored IP in the file
   - manually calls the `/etc/rc.dyndns.update` script

This way, the Cloudflare record always points to the correct public IP.

❗ Script: [/11-Scripts/pfsense/ddns-force-update.sh](/11-Scripts/pfsense/ddns-force-update.sh)

---

## Apt-cacher-ng stuck package issue

<a name="aptcacherng"></a>

**Problem**
During client updates via Ansible, I noticed in the Semaphore GUI that it sometimes wouldn't finish — it would just hang and wait indefinitely. This can be seen in the image below.
<p align="center">
  <img src="https://github.com/user-attachments/assets/db0a18b6-dd7c-45b4-83cc-b9f97840c7f8" alt="Description" width="600">
</p>

**Cause**

- On the proxy server: tail -f /var/log/apt-cacher-ng/apt-cacher.err –> shows the cache errors, as seen in the image below.
- The client requests the package from the proxy server (apt-cacher-ng).
- The apt-cacher-ng database sees that the downloaded package's file size doesn't match what its database says the file should officially be (checked size beyond EOF).
- The proxy tries to re-download the faulty file, but can't, since a file with that name already exists (even if corrupted) (file exists), so the client **waits indefinitely for the package**.
<p align="center">
  <img src="https://github.com/user-attachments/assets/3563cca6-e744-4dbe-b23f-4ae2823db9ac" alt="Description" width="600">
</p>


**Solution**

The acngtool maintenance command was added to cron, running every day at 22:30. This automatically cleans and rebuilds the cache, avoiding the stuck state, right before the 23:00 Ansible-driven update playbook, thereby avoiding the hang.

30 22 * * * /usr/lib/apt-cacher-ng/acngtool maint -c /etc/apt-cacher-ng >/dev/null 2>&1

---

## AWS – DNS override conflict (BIND9 wildcard vs EC2 subdomain)
<a name="dns-override-aws"></a>

**Problem**:
- EC2 services didn't load on the home network, but did on mobile data.

**Cause**:
- The homelab BIND9 has a `*.trkrolf.com` wildcard override, which routes everything to the local Traefik, so the EC2 subdomains never even reached Cloudflare.

<img width="691" height="255" alt="image" src="https://github.com/user-attachments/assets/b55f6d2a-6a33-40c0-b048-38c288e24153" />

**Solution**:
- Creating an exception in AdGuard Home for the EC2 subdomains, so they don't go to the overridden BIND9, but instead resolve to the Cloudflare proxy IP.

Finding the Cloudflare proxy IP:

```bash
nslookup gotifyaws.trkrolf.com 1.1.1.1
ipconfig /flushdns
```

<img width="726" height="379" alt="image" src="https://github.com/user-attachments/assets/df18226d-62c7-428f-9510-0b144f2ac834" />

Here you can see the AdGuard override.

<img width="945" height="430" alt="image" src="https://github.com/user-attachments/assets/f5d775b8-ba9e-4cc4-b31e-45ea16fe90d3" />

---

## AWS – Cloudflare wildcard certificate limit
<a name="cf-wildcard-limit"></a>

**Problem**:
- `uptime.aws.trkrolf.com` — SSL Handshake Failure, reachable over http but not https.

**Cause**:
- Cloudflare Universal SSL (free plan) only covers a single-level wildcard (`*.trkrolf.com`). `uptime.aws.trkrolf.com` is a third-level subdomain, so it falls outside that scope.

**Solution**:
- Renaming the subdomains to single-level in the Cloudflare tunnel: `uptimeaws.trkrolf.com`, `gotifyaws.trkrolf.com`, which are already covered by the `*.trkrolf.com` wildcard.

<img width="1603" height="415" alt="image" src="https://github.com/user-attachments/assets/078d4589-e97a-451f-9324-f4e315711493" />

> **Important:** With Cloudflare's free plan, it's always worth planning single-level subdomains if you're using a wildcard cert — otherwise you'd need Total TLS, which is a paid feature.

---

← [Back to Homelab main page](../README.md)
