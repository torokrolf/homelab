← [Back to the Homelab main page](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Design Decisions and Rationale

Here I present why I chose certain technologies and architectural approaches.

---

## Proxmox and VMs initially sharing a 1TB M.2 SSD, later separating them: Proxmox moved to a 250 GB SSD, VMs to the fast 1 TB M.2 SSD

- **Space saving**: This way, a Clonezilla backup is only required for the 250 GB SSD that contains Proxmox. The VMs are backed up by Proxmox Backup Server (PBS), so Clonezilla backups for them are unnecessary. Result: faster backups and significantly less storage usage.
- **I/O load separation**: Both the Proxmox host and the VMs perform I/O operations. If they share the same disk, the load adds up. Using separate SSDs distributes the load, resulting in a more stable and faster system.

---

## Replacing FreeFileSync with Restic

- I back up the important files from my new laptop to the TrueNAS server using **Restic**.
- Why Restic:
  - **Safe**: With Restic, accidentally deleted source files can be restored. With FreeFileSync, if I accidentally sync after deleting a source file, I cannot recover it.
  - **Versioning**: Previous file states can be restored at any time.
  - **Efficient**: Compressed, fast. FreeFileSync was much slower at detecting changes and copying modified files.

---

## Why Nextcloud?

- Self-hosted file and photo management  
- No need for Google Drive or other cloud services — Nextcloud is my own Google Drive  
- Full control and security  

---

## Why Vaultwarden?

- Self-hosted password manager  
- Passwords never leave my infrastructure  
- Full control and security  

---

## I run every possible service in LXC, each service in its own container

The main goal is that **each service runs in a separate LXC**, ensuring isolation: if one container stops, it **does not affect the other services**.

**Advantages of using LXC compared to VMs:**

- **Lower resource usage**: requires less RAM and CPU, faster startup
- **Faster deployment**: new containers can be created in minutes
- **Scalability**: more containers can run on a host than VMs
- **Isolation**: a failing or stopped service does not bring down others

---

## My mounting strategy

- On Proxmox1 node there is no disk passthrough
- On Proxmox2 node there are 2 disk passthroughs (for TrueNAS and Proxmox Backup Server)
- I mount the TrueNAS shares to the Proxmox host so it can pass them to unprivileged LXCs.
- In the case of VMs, I mount the TrueNAS shares directly inside the VM via `fstab`, not through Proxmox.

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

## Bind9, AdGuard Home, and Unbound Cache/TTL Strategy

**BIND9 (Local Authoritative Source):**
- Since pfSense assigns static IPs, the IP addresses of my private domains remain constant; services are always mapped to the same IP.
- A **1-hour (3600s) TTL** in the zone files provides an ideal balance between stability and flexibility for testing and updates.

**Unbound (Recursive Resolver):**
- **TTL Capping (0-3600s)**: Unbound respects the original TTL but caps it at 1 hour. This protects against stale records while allowing CDNs to offer closer or faster servers via short TTLs (e.g., 10s).
- **Optimistic Caching**: Using the `serve-expired` feature, expired records are retained for an additional hour. If the upstream server is unavailable or slow, Unbound responds instantly from the cache, making network errors or latency invisible to clients.

**AdGuard Home (Client-side Filter):**
- **TTL Range (0-86400s)**: The maximum limit is raised to 1 day.
- **Optimistic Caching**: AdGuard also utilizes this feature. If the BIND9 container or Unbound were to go down temporarily, AdGuard can serve known internal names from its cache for up to 24 hours, ensuring continuous access to homelab services.

Layer / Server                 | Cache Size                          | Minimum TTL | Maximum TTL
-------------------------------|-------------------------------------|-------------|-------------
AdGuard Home (for clients)     | 128 MB                              | 0           | 86400 (1 day)
BIND9 (local zones)            | default                             | 3600        | 3600
Unbound (public DNS)           | msg-cache 64 MB, rrset-cache 128 MB | 0           | 3600 (1 hour)

---

← [Back to the Homelab main page](../README.md)
