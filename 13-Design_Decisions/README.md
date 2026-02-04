← [Back to Homelab Main Page](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Design Decisions and Arguments

This section outlines why I chose specific technologies and architectures for my homelab.

---

## Storage Strategy: Separating OS and VMs
**Current:** Proxmox and VMs share a 1TB M.2 SSD.  
**Planned:** Proxmox OS moves to a 250GB SSD, while VMs stay on the fast 1TB M.2 SSD.

- **Simplified Backups**: Clonezilla backups will only be necessary for the 250GB OS drive. Since VMs are backed up via Proxmox Backup Server (PBS), they don't need image-level backups. This results in faster, smaller, and more efficient backups.
- **I/O Load Separation**: Both the Proxmox host and the VMs perform constant I/O operations. By separating them onto different physical disks, we eliminate I/O contention, ensuring a more stable and responsive system.

---

## Switching from FreeFileSync to Restic

- I use **Restic** to back up important files from my laptop to the TrueNAS server.
- **Why Restic?**
    - **Security/Safety**: Unlike FreeFileSync, where an accidental deletion in the source might be synced (and thus lost), Restic allows for point-in-time recovery of deleted files.
    - **Versioning**: Multiple snapshots allow for restoring previous states of files.
    - **Efficiency**: It features built-in compression and deduplication. FreeFileSync was significantly slower at checking for changes and transferring data.

---

## Nextcloud
- Self-hosted file and photo management.
- Replaces Google Drive/Cloud services; Nextcloud is my private "Google Drive."
- Provides full control and data privacy.

---

## Vaultwarden
- Self-hosted password management.
- Passwords never leave the local network.
- Full control and enterprise-grade security (Bitwarden compatible).

---

## Service Isolation: One Service per LXC

The primary goal is to run **each service in its own LXC container** to ensure isolation: if one container fails, it **does not affect the others**.

**Advantages of LXC over VMs:**
- **Resource Efficiency**: Lower RAM and CPU overhead, with near-instant boot times.
- **Rapid Deployment**: New containers can be spun up in minutes.
- **Scalability**: High density; a single host can run significantly more containers than VMs.
- **Isolation**: A crashed or misconfigured service stays contained within its own environment.

---

## Mounting Strategy

- **Proxmox1**: No disk passthrough used.
- **Proxmox2**: Uses 2 disk passthroughs (one for TrueNAS and one for Proxmox Backup Server).
- **LXC Mounts**: Network shares are mounted on the Proxmox host first, then passed to unprivileged LXC containers via bind mounts for security.
- **VM Mounts**: VMs mount TrueNAS shares directly via `/etc/fstab`, as they do not share the host kernel like LXC containers do.

```mermaid
flowchart TB
    %% Smooth lines
    linkStyle default interpolate basis

    %% Top row: Proxmox nodes side by side
    subgraph PROXMOX["Proxmox Nodes"]
        direction LR
        PVE1["Proxmox1"]
        PVE2["Proxmox2"]
    end

    %% Passthrough disks going directly to VMs (middle layer)
    SSD_TRUENAS["SSD Passthrough → TrueNAS (VM)"]
    SSD_PBS["Disk Passthrough → PBS (VM)"]

    %% Passthrough connections (PVE2 only)
    PVE2 --> SSD_TRUENAS
    PVE2 --> SSD_PBS

    %% TrueNAS storage exports
    SSD_TRUENAS --> NFS["NFS Share: torrent"]
    SSD_TRUENAS --> SMB1["SMB Share: backup"]
    SSD_TRUENAS --> SMB2["SMB Share: pxeiso"]

    %% Proxmox1 mounts the shares
    PVE1 --> NFS
    PVE1 --> SMB1
    PVE1 --> SMB2

    %% Consumers (bottom row)
    subgraph CONSUMERS["VM/LXC Consumers"]
        direction LR
        JELLY["LXC 1010 Jellyfin\nProxmox-mounted"]
        SERVARR["LXC 1011 Servarr\nProxmox-mounted"]
        RESTIC["LXC 1008 Restic\nProxmox-mounted"]
        PXEVM["VM 209 PXEBoot\nfstab mount"]
    end

    %% Storage → Consumers connections
    NFS --> JELLY
    NFS --> SERVARR
    SMB1 --> RESTIC
    SMB2 --> PXEVM

---

← [Back to Homelab Main Page](../README.md)
