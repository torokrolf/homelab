← [Back to Homelab main page](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Errors

## 📚 Table of Contents

- [DNS – Public domain resolution without internet](#dns-offline)
- [DNS – Pi-hole blocks Google image search](#dns-pihole)
- [DNS – ARP starving caused by AdGuard rate limit](#ratelimit)
- [SSH – SSH login for LXC / Ubuntu](#ssh-lxc)
- [Share – SMB/NFS access from LXC](#mount-lxc)
- [Share – when the TrueNAS share is unavailable](#nemelerheto)
- [Hardware – External SSD stability over USB](#hw-ssd)
- [Hardware – M70q network adapter instability](#hw-m70q)
- [Hardware – Local and public DNS issues (Wi-Fi)](#hw-wifi)
- [DDNS – Cloudflare update behind pfSense](#ddns-pfsense)
- [Apt-cacher-ng package stalling](#aptcacherng)
- [AWS – DNS override conflict (BIND9 wildcard vs EC2 subdomain)](#dns-override-aws)
- [AWS – Cloudflare wildcard certificate limit](#cf-wildcard-limit)
- [Terraform – LXC template lock error on parallel cloning (Important: this error never occurred with Proxmox VM templates!)](#lxc-parhuzamos-vegrehajtas)
- [Terraform – LXC cloned container disk.size doesn't apply in one `apply`](#lxcklonozashiba)

---

## DNS – Public domain resolution without internet
<a name="dns-offline"></a>

**Problem**:
- Accessing the `*.trkrolf.com` public domain failed without an internet connection.

**Solution**:
- **DNS override**: The wildcarded trkrolf.com (`*.trkrolf.com`) records resolve directly to the local Traefik IP on the internal network, bypassing the external lookup.

---

## DNS – Pi-hole blocks Google image search on mobile
<a name="dns-pihole"></a>

**Problem**:
- Google image search results wouldn't open on mobile because of Pi-hole's blocklists.

**Cause**:
- Google uses tracking domains (e.g. `googleadservices.com`) that are on the blocklists.

**Solution**:
- Temporary Pi-hole disable via an SSH script.

❗ Script: [/11-Scripts/Android/toggle_pihole_ssh.sh](/11-Scripts/Android/toggle_pihole_ssh.sh)

---

## DNS – ARP starving caused by AdGuard DNS rate limit
<a name="ratelimit"></a>

**Problem description**
After switching from Pi-hole to AdGuard Home, the Proxmox hosts (192.168.2.198, 192.168.2.199) became unreachable from the 192.168.1.0/24 network. Interestingly, the VMs and LXC containers running on those hosts remained pingable, but the physical nodes themselves did not respond.

**Cause**

- **DNS rate limit:** AdGuard Home's default rate limit (**20 queries/sec**) was too low. Clients exceeded it, and AdGuard Home started dropping requests.
- **DNS flood:** Clients began aggressively retrying due to the failed lookups, increasingly often, which overloaded the Proxmox network interface — a self-reinforcing loop.
  **Missing records:** Since the Proxmox nodes had fixed IPs (not assigned via pfSense DHCP), they had no static ARP entry enabled in pfSense. Due to the network noise, they couldn't get into the ARP table, resulting in **ARP starving**.
- **ARP starving:** The large number of dropped packets and the resulting queueing meant the Proxmox interface couldn't respond in time to pfSense's ARP requests, which are needed for PING. The VMs and LXCs on the Proxmox node remained pingable from 1.0 because they got their IP from the pfSense DHCP server, where static ARP was also configured for them — so their IP + MAC pairing was known.

**Solution**

1.  **Fixing static ARP:**
    * Added the Proxmox hosts to the **DHCP Static Mappings** list in pfSense.
    * After registering the MAC addresses, enabled the **Static ARP** option, so the router no longer needs ARP requests to find the hosts.
2.  **Raising the AdGuard Home limit:**
    * In the AdGuard UI: Settings / DNS settings / Rate limit.

---

## SSH – SSH login for LXC / Ubuntu
<a name="ssh-lxc"></a>

**Problem**:
- Root SSH login is disabled by default inside LXC containers.

**Solution**:
- Created a regular user and set up SSH key-based authentication.

---

## Share – SMB/NFS access from LXC
<a name="mount-lxc"></a>

**Problem**:
- Unprivileged LXC containers can't mount a network share directly.

**Solution**:
- The share is mounted on the Proxmox host with **systemd.automount**, then passed through to the LXC via a bind mount (`mp0`).
- This avoids the `df` command hanging when the storage is unavailable, since systemd.automount only attempts to mount the share on the first actual access — until then, it doesn't try to connect to a NAS that might not be available.

---

## Share – when the TrueNAS share is unavailable
<a name="nemelerheto"></a>

**Problem**:
- Since several VMs and LXCs on my Proxmox1 node use the TrueNAS share, it's a real problem what happens when that share becomes unavailable. For example, when the share was unavailable, qBittorrent kept downloading onto the VM's local storage instead, which is a problem.

**Solution**:
The best solution I found is to stop the LXC and VM at that point — since I follow a one-service-per-VM/LXC principle anyway, this doesn't affect any other service. Once the share becomes available again, I start the VM/LXC back up.

- The share is managed on the Proxmox host with **systemd.automount** (on-demand mounting), and passed to the LXCs via a bind mount (`mp0`).
- A systemd timer runs a script (`mount-watchdog.sh`) every 30 seconds, which **pings** the TrueNAS host (checking host reachability, not the filesystem/mount itself) — this reacts faster than waiting for a mount timeout.
- The script stores the previous state (UP/DOWN) in a **state file**, and only takes action if there's been a **change** since the last check — so there's no unnecessary starting/stopping of VMs/LXCs on every 30-second cycle.
- On a state change:
  - **DOWN → UP**: starts the affected VMs and LXCs, and scales the media services (bazarr, prowlarr, qbittorrent, radarr, seerr, sonarr) back up to 1 replica at the app level on the K3s server (`kubectl scale`).
  - **UP → DOWN**: stops the affected VMs/LXCs, and scales the K3s apps down to 0 replicas.
- All start/stop actions run **in parallel** (as background jobs, using `&` and `wait`), not sequentially, minimizing the critical reaction time.
- After a reboot, the state file is automatically deleted once, so the script decides based on the system's actual current state rather than a stale entry.
- I get a Gotify notification on every state change (NAS became available / NAS became unavailable).

❗ Script: [/11-Scripts/proxmox/mount-watchdog.sh](/11-Scripts/proxmox/mount-watchdog.sh)

The image below shows that when I stopped TrueNAS, the affected VM/LXC machines on the other Proxmox node stopped as well. If I start TrueNAS back up, those machines start again too.
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
- The M70q's built-in network card (`eno2`, Intel e1000e) randomly dropped off the LAN, and often only came back after a reboot.

**Diagnostics**:
- When the connection dropped, I sat down at the Proxmox host and checked what happened at the driver level with:
```bash
dmesg | grep eno2
```
- The log pointed to e1000e driver errors/resets, suggesting this was a driver/hardware-level instability rather than a software issue (e.g. DHCP, cabling).

<img width="738" height="247" alt="image" src="https://github.com/user-attachments/assets/0cb35fe9-ac9c-418c-b03c-cc9f931c3365" />

**Attempted solutions**

**Attempt 1 – tuning e1000e driver parameters (did not work)**

   Created the file, since it didn't exist yet:
```bash
   sudo nano /etc/modprobe.d/e1000e.conf
```
   Contents:

options e1000e InterruptThrottleRate=2000
options e1000e TxIntDelay=16
options e1000e RxIntDelay=16
options e1000e InterruptModeration=1
options e1000e FlowControl=1

Followed by a reboot. This setting alone did not fix the random disconnects.

**Attempt 2 – watchdog script to automatically restart the interface (a good direction in principle, but didn't run long enough to confirm real stability)**

   The idea: a custom "WDT" (watchdog timer) — the script regularly pings a reachable device (e.g. the router), and if it gets no reply, brings the `eno2` interface down and back up.

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

   A systemd service was also created so it runs continuously and restarts itself if it stops:
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
- Instead of driver-level tuning or the watchdog script, using a **TP-Link UE330 external USB Ethernet adapter** ultimately solved the problem for good — it has run flawlessly, without any dropouts, ever since.

---

## Hardware – Local and public DNS issues due to Wi-Fi adapter
<a name="hw-wifi"></a>

**Problem**:
- The MediaTek 7921 Wi-Fi card produced unstable DNS resolution on Linux.

**Solution**:
- Replaced the adapter with an Intel AX210.

---

## DDNS – pfSense DDNS doesn't update Cloudflare behind Double NAT
<a name="ddns-pfsense"></a>

**Problem**

The pfSense WAN interface doesn't have a **public IP**, but a **static private IP (e.g. 192.168.1.196)**, because the router sits behind double NAT.

pfSense's built-in Dynamic DNS mechanism (`/etc/rc.dyndns.update`) is triggered in 3 cases:

- on system boot
- when the WAN interface gets a new IP
- when the WAN interface goes down/up

Since the IP on the WAN interface doesn't change, pfSense **doesn't detect** that the actual public IP on the upstream router has changed, so it never updates the Cloudflare DNS record.

Result: the trkrolf.com domain becomes unreachable from outside.

**Solution**

A script forces pfSense to react to a change in the **actual public IP**, instead of the WAN IP.

The mechanism:

- Queries the current public IP via checkip.amazonaws.com
- Compares it to the previously stored IP, kept in a file
- If it changed:
   - updates the stored IP in the file
   - manually invokes the `/etc/rc.dyndns.update` script

This way the Cloudflare record always points to the correct public IP.

❗ Script: [/11-Scripts/pfsense/ddns-force-update.sh](/11-Scripts/pfsense/ddns-force-update.sh)

---

## Apt-cacher-ng stalled package problem

<a name="aptcacherng"></a>

**Problem**
During Ansible-driven client updates, I noticed in the Semaphore GUI that a run would sometimes just hang and wait indefinitely, as shown in the image below.
<p align="center">
  <img src="https://github.com/user-attachments/assets/db0a18b6-dd7c-45b4-83cc-b9f97840c7f8" alt="Description" width="600">
</p>

**Cause**

- On the proxy server: `tail -f /var/log/apt-cacher-ng/apt-cacher.err` — shows the cache errors, as seen in the image below.
- The client requests the package from the proxy server (apt-cacher-ng).
- apt-cacher-ng's database sees that the downloaded package's file size doesn't match what its database says the file should officially be ("checked size beyond EOF").
- The proxy tries to re-download the broken file, but can't, since a file with that name already exists (even if corrupted) — so the client **waits for the package indefinitely**.
<p align="center">
  <img src="https://github.com/user-attachments/assets/3563cca6-e744-4dbe-b23f-4ae2823db9ac" alt="Description" width="600">
</p>

**Solution**

Put the `acngtool` maintenance command into cron, running every day at 22:30. This automatically cleans and rebuilds the cache, preventing the stall, right before the 23:00 Ansible-driven update playbook — avoiding the hang.

30 22 * * * /usr/lib/apt-cacher-ng/acngtool maint -c /etc/apt-cacher-ng >/dev/null 2>&1

---

## AWS – DNS override conflict (BIND9 wildcard vs EC2 subdomain)
<a name="dns-override-aws"></a>

**Problem**:
- EC2 services didn't load on the home network, but did work on mobile data.

**Cause**:
- The homelab BIND9 has a `*.trkrolf.com` wildcard override, which routes everything to the local Traefik, so the EC2 subdomains never even reached Cloudflare.

<img width="691" height="255" alt="image" src="https://github.com/user-attachments/assets/b55f6d2a-6a33-40c0-b048-38c288e24153" />

**Solution**:
- Created an exception in AdGuard Home for the EC2 subdomains, so they don't go to the overridden BIND9, but resolve to the Cloudflare proxy IP instead.

Finding the Cloudflare proxy IP:

```bash
nslookup gotifyaws.trkrolf.com 1.1.1.1
ipconfig /flushdns
```

<img width="726" height="379" alt="image" src="https://github.com/user-attachments/assets/df18226d-62c7-428f-9510-0b144f2ac834" />

The AdGuard override shown here.

<img width="945" height="430" alt="image" src="https://github.com/user-attachments/assets/f5d775b8-ba9e-4cc4-b31e-45ea16fe90d3" />

Success.

<img width="439" height="163" alt="image" src="https://github.com/user-attachments/assets/675a1b2f-4b0d-4cb7-a51c-e7dd17db137f" />

---

## AWS – Cloudflare wildcard certificate limit
<a name="cf-wildcard-limit"></a>

**Problem**:
- `uptime.aws.trkrolf.com` — SSL handshake failure; reachable over HTTP but not HTTPS.

**Cause**:
- Cloudflare's Universal SSL (free tier) only covers a single-level wildcard (`*.trkrolf.com`). `uptime.aws.trkrolf.com` is a third-level subdomain, so it falls outside that scope.

**Solution**:
- Renamed the subdomains to single-level in the Cloudflare tunnel: `uptimeaws.trkrolf.com`, `gotifyaws.trkrolf.com`, which are already covered by the `*.trkrolf.com` wildcard.

<img width="1603" height="415" alt="image" src="https://github.com/user-attachments/assets/078d4589-e97a-451f-9324-f4e315711493" />

> **Important:** With the Cloudflare free tier, always plan single-level subdomains if using a wildcard cert — otherwise you need Total TLS, which is paid.

---
<a name="lxc-parhuzamos-vegrehajtas"></a>

## Terraform – LXC template lock error on parallel cloning (Important: this error never occurred with Proxmox VM templates!)

**Problem:**
If multiple LXC containers are cloned from the same template at the same time (or Terraform's default parallel execution tries to create several resources simultaneously), Proxmox locks the template during cloning. As a result, the other clone operation running in parallel fails with a "template is locked" error, because the source template is still busy from the previous clone.

The image below shows the LXC template getting locked while another LXC (e.g. dns-201) is being cloned from it. Because of this, no one else can clone from the locked LXC template at that moment.

<img width="323" height="269" alt="image" src="https://github.com/user-attachments/assets/15bcdbce-4bf3-4e41-be07-81543ba33c5d" />
<img width="769" height="329" alt="image" src="https://github.com/user-attachments/assets/7eb3dff6-d8a1-4f4b-8929-e727daf50180" />

**Solution:**
The `-parallelism=1` flag in the workflow's `apply` command ensures Terraform creates resources sequentially, one after another, instead of in parallel:

```bash
terraform_cmd apply -auto-approve -parallelism=1
```

This way, the first LXC clone finishes completely (releasing the template lock) before the next clone starts — no conflict on the template lock.

---
<a name="lxcklonozashiba"></a>

## Terraform – LXC cloned container disk.size doesn't apply in one `apply`

**Problem:**
When cloning a 5GB LXC template, I can modify memory size, MAC address, everything in one pass — except the disk, e.g. resizing the LXC template from 5GB to 10GB.
The `bpg/proxmox` Terraform provider (up to and including v0.112.0) ignores the `disk.size` field during LXC container cloning (`clone` block) — the new container inherits the source template's original size. The actual resize (the Proxmox `pct resize` API call) only runs in the provider's Update step, which is only triggered if the Terraform state and the size specified in the config differ. Because of this, after running a single `apply`, the state shows the requested size, but the actual Proxmox container remains at the (smaller) size it had at the moment of cloning — the real resize only happens on the **second** `apply` run.

**Solution:**
The `apply` stage of the `.github/workflows/terraform.yml` workflow runs two consecutive `terraform apply` commands:

```bash
terraform_cmd apply -auto-approve -parallelism=1
terraform_cmd apply -auto-approve -parallelism=1
```

The 1st pass creates/clones the new resources, and the 2nd pass enforces the `disk.size` (a live resize, which for LXC doesn't require a container restart). If there's no new cloning in a given run, the 2nd pass is simply a no-op.

The GUI marks the change in yellow, but `df` already shows 10GB — the resize works, the yellow indicator is just a GUI quirk and disappears after a reboot.

<img width="980" height="438" alt="image" src="https://github.com/user-attachments/assets/adad71b9-5360-41d0-bc40-42c61e83dafc" />

---

← [Back to Homelab main page](../README.md)
