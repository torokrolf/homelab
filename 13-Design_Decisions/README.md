← [Back to Homelab main page](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Design Decisions and Rationale

Here I present why I chose certain technologies and architectural approaches.

---
## Proxmox and VMs initially sharing a 1TB M.2 SSD, later separating them so Proxmox moves to a 250 GB SSD while VMs remain on the fast 1 TB M.2 SSD

- **Space saving**: This way, Clonezilla backup is only required for the 250 GB SSD containing Proxmox. The VMs are backed up by Proxmox Backup Server (PBS), so Clonezilla backup for them is unnecessary. Result: faster backups and less storage usage.
- **I/O load separation**: The Proxmox host and the VMs both perform I/O operations. If they were on the same disk, the load would accumulate. With separate SSDs, operations are distributed, providing a more stable and faster system.

---
## Replacing FreeFileSync with Restic

- I back up the important files from my new laptop to the TrueNAS server using **Restic**.
- Why Restic:
  - **Safe**: With Restic, accidentally deleted source files can be restored. With FreeFileSync, if I sync after deleting a source file, I cannot restore it.
  - **Versioning**: Previous states can be restored at any time.
  - **Efficient**: Compression, fast operation. FreeFileSync was much slower at detecting changes and copying modified files.

---
## Why Nextcloud?

- Self-hosted file and photo management
- No need for Google Drive / other cloud providers — Nextcloud is my own Google Drive
- Full control and security

---
## Why Vaultwarden?

- Self-hosted password manager
- Passwords never leave my infrastructure
- Full control and security

---
## I run every possible service as an LXC, each service in its own LXC

The main goal is that **every service runs in its own LXC**, fully isolated. If one container stops, it **does not affect other services**.

**Advantages of LXC compared to VMs:**
- **Lower resource usage**: less RAM and CPU required, faster startup
- **Faster deployment**: new containers can be created in minutes
- **Scalability**: more containers fit on a host than VMs
- **Isolation**: a failed service does not bring down others

---

## My mounting strategy

- No disk passthrough on Proxmox1 node
- On Proxmox2 node there are 2 disk passthroughs (for TrueNAS and Proxmox Backup Server)
- I mount TrueNAS shares to the Proxmox host, which then passes them to unprivileged LXCs
- In the case of VMs, I mount TrueNAS shares directly inside the VM via fstab, not through Proxmox

```mermaid
flowchart TB
    linkStyle default interpolate basis

    subgraph PROXMOX["Proxmox Nodes"]
        direction LR
        PVE1["Proxmox1"]
        PVE2["Proxmox2"]
    end

    SSD_TRUENAS["SSD Passthrough → TrueNAS (VM)"]
    SSD_PBS["Disk Passthrough → PBS (VM)"]

    PVE2 --> SSD_TRUENAS
    PVE2 --> SSD_PBS

    SSD_TRUENAS --> NFS["NFS Share: torrent"]
    SSD_TRUENAS --> SMB1["SMB Share: backup"]
    SSD_TRUENAS --> SMB2["SMB Share: pxeiso"]

    PVE1 --> NFS
    PVE1 --> SMB1
    PVE1 --> SMB2

    subgraph CONSUMERS["VM/LXC Consumers"]
        direction LR
        JELLY["LXC 1010 Jellyfin\nProxmox-mounted"]
        SERVARR["LXC 1011 Servarr\nProxmox-mounted"]
        RESTIC["LXC 1008 Restic\nProxmox-mounted"]
        PXEVM["VM 209 PXEBoot\nfstab mount"]
    end

    NFS --> JELLY
    NFS --> SERVARR
    SMB1 --> RESTIC
    SMB2 --> PXEVM
```

---

## Bind9, AdGuard Home, Unbound cache and TTL strategy

**BIND9 (Local authoritative source):**
- Since pfSense assigns static IPs, internal service addresses are constant, the name-IP mapping does not change.
- The **1 hour (3600s) TTL** in zone files creates an ideal balance between stability and flexibility during testing.

**Unbound (Recursive resolver):**
- **TTL Capping (0–3600s)**: Unbound respects the original TTL but caps it at 1 hour.
- **Optimistic Caching**: With serve-expired enabled, expired records are kept for another hour.

**AdGuard Home (Client-side filtering):**
- **TTL range (0–86400s)**: Maximum limit raised to 1 day.
- **Optimistic caching**: Ensures availability even if BIND9/Unbound stops.

Layer / Server                | Cache Size                               | Minimum TTL | Maximum TTL
-----------------------------|-------------------------------------------|-------------|-------------
AdGuard Home (for clients)  | 128 MB                                    | 0           | 86400 (1 day)
BIND9 (local zones)         | default                                   | 3600        | 3600
Unbound (public DNS)        | msg-cache 64 MB, rrset-cache 128 MB       | 0           | 3600 (1 hour)

---

## Scheduled Tasks (Backup & Maintenance)

**Explanation of the scheduling logic:**
- **01:00 Short SMART test**: This ensures I am aware by morning whether the disks are healthy and if it is safe to perform operations on them.
- **02:00 Long SMART test (First Saturday of every month)**: Provides a deeper analysis of disk health to ensure long-term data integrity.
- **04:00/05:30 Backup**: Scheduled for the early morning because network traffic and CPU load are at their lowest. The two nodes (PVE1 and PVE2) start with an offset to avoid overloading the PBS server's write speed and network bandwidth simultaneously.
- **08:00 Garbage Collection (Saturdays)**: Cleans up the backup storage to reclaim space.
- **10:00 Verification (Sundays)**: Checking once a week is sufficient to ensure that the files are truly restorable; it is essential to verify that the backups are intact, not just present.
- **22:00 Prune**: Deleting backups that are no longer needed based on the retention policy, making room for the next morning's backups.
- **22:30 Apt-Cacher-NG Maint**: Fixing the proxy cache right before updates ensures that Ansible can update the VM/LXC machines without errors.
- **23:00 Ansible Update**: Updating happens when daily usage has decreased, ensuring that minor service interruptions do not cause major disturbances.

**The timing diagram below shows the measured duration of each task. For Proxmox VM/LXC backups, keep in mind that the first backup takes the longest, while subsequent backups are incremental and much faster.**

```mermaid
gantt
    title Optimized System Task Scheduling
    dateFormat  HH:mm
    axisFormat  %H:%M
    todayMarker off

    section Daily Routine
    Prune                        : 22:00, 1m
    Apt-Cacher-NG Maint          : 22:30, 1m
    Ansible Update               : 23:00, 5m
    SMART Short Test             : 02:00, 5m

    section Backup Window
    PVE1 -> PBS Backup           :crit, 04:00, 15m
    PVE2 -> PBS Backup           :crit, 05:30, 5m

    section Maintenance
    SMART Long (Monthly)         :done, 01:00, 4h
    Garbage Collection (Sat)     :done, 08:00, 1m
    Verify Jobs (Sun)            :done, 10:00, 20m
```

| Time | Task Name | Target Device | Frequency | Duration |
| :--- | :--- | :--- | :--- | :--- |
| **22:00** | Prune (Retention) | PBS Server | Daily | 1 min |
| **22:30** | Apt-Cacher-NG Maintenance | Apt-Proxy Server | Daily | 1 min |
| **23:00** | Ansible Update | VM/LXC | Daily | - |
| **01:00** | SMART Long Test | Proxmox 1 & 2 | Monthly (1st Sat) | - |
| **02:00** | SMART Short Test | Proxmox 1 & 2 | Daily | - |
| **04:00** | VM/LXC Backup | Proxmox 1 -> PBS | Weekly (Sunday) | 15 min |
| **05:30** | VM/LXC Backup | Proxmox 2 -> PBS | Weekly (Sunday) | 5 min |
| **Sat 08:00** | Garbage Collection | PBS Server | Weekly | 1 min |
| **Sun 10:00** | Backup Verification (Verify) | PBS Server | Weekly/Monthly | 20 min |

---

## Confusion caused by identical VM/LXC IDs in Proxmox Backup Server

**Problem**

When using multiple Proxmox nodes, PBS (Proxmox Backup Server) organizes backups by default based on VM/LXC IDs. If identical IDs are used (e.g., 101 on Node1 and 101 on Node2), I ran into the following issue: the PBS interface does not distinguish which node the given VM/LXC backup came from. As a result, backups from two different machines are placed under the same identifier and are not separated.

**Solution**

Use **globally unique VM/LXC IDs**, assigned according to a structured system rather than randomly, based on the table below.

I am renumbering my current system according to this table, and when creating new VM/LXC instances, I assign IDs following this structure. Every VM/LXC is registered in a table so I always know which ID is assigned to which machine.

| ID Range | Category | Notes |
| :--- | :--- | :--- |
| **100 - 499** | **LXC Core infrastructure** | Essential LXCs required for operation |
| **500 - 999** | **VM Core infrastructure** | Essential virtual machines required for operation |
| **1000 - 1099** | **LXC services** | Additional service containers |
| **1100 - 1199** | **VM Linux servers** | Linux-based servers |
| **1200 - 1299** | **VM Linux clients** | Linux-based clients |
| **1300 - 1399** | **VM Windows servers** | Windows-based servers |
| **1400 - 1499** | **VM Windows clients** | Windows-based clients |

**My current allocation**

**LXC Core infrastructure (100-499)**
- `100:dns`, `101:unbound`, `102:traefik`, `103:adguard`, `104:pi-hole`, `105:nginx`

**VM Core infrastructure (500-999)**
- `500:pfsense`, `501:pbs`, `502:truenas`

**LXC Services (1000-1099)**
- `1000:zabbix`, `1001:ansible`, `1002:nextcloud`, `1003:homarr`, `1004:guacamole`, `1005:apt-cacher`, `1006:freeipa`, `1007:freeradius`, `1008:restic`, `1009:vaultwarden`, `1010:jellyfin`, `1011:servarr`, `1012:gotify`, `1013:portainer`, `1014:pulse`, `1015:changedetection`

**VM Linux servers (1100-1199)**
- `1100:crowdsec`, `1101:pxeboot`

**VM Linux clients (1200-1299)**
- `1200:mainubuntu`, `1201:kali`, `1202:probaubi`

**VM Windows servers (1300-1399)**
- `1300:winszerver1`, `1301:winszerver2`, `1302:winszerver-core`

**VM Windows clients (1400-1499)**
- `1400:mainwindows11`, `1401:win11kliens1`, `1402:win11kliens2`

---

## My VM/LXC naming convention

The VM/LXC name refers to the service or role running on it, extended with the last octet of its IP address. This way, at a glance, I know what it does and what its IP address is. For example, `traefik-224` clearly shows that Traefik runs on it and its IP address is `192.168.2.224`.

<p align="center">
  <img src="https://github.com/user-attachments/assets/411bfb50-f4b9-4a76-b464-794a79a88299" alt="Description" width="400">
</p>

---

← [Back to Homelab main page](../README.md)
