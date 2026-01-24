← [Back to the Homelab main page](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Hungarian](README_HU.md)

---

## Design decisions and reasoning

This document explains **why I chose specific technologies and architectures**, and **why I use them the way I do** in my homelab setup.  
The main goals are **clarity, reliability, easy maintenance, and full control** over my own infrastructure.

---

## Proxmox on a smaller (250 GB) SSD, VMs on a separate fast 1 TB M.2 SSD

- **Space saving**: Clonezilla backups are only required for the 250 GB Proxmox system SSD, since virtual machines are backed up using Proxmox Backup Server (PBS). This avoids unnecessary backups of the larger 1 TB VM disk, making backups faster and more storage-efficient.
- **I/O separation**: Both the Proxmox host and the VMs perform disk I/O. Keeping them on separate SSDs prevents I/O contention, resulting in better performance and improved system stability.

---

## Replacing FreeFileSync with Restic

- Important files on my laptop are backed up to the TrueNAS server using **Restic**.
- Reasons for choosing Restic:
  - **Safety**: Accidentally deleted files can be restored. With FreeFileSync, an accidental sync after deletion may permanently remove files.
  - **Versioning**: Previous versions and historical states can be restored.
  - **Efficiency**: Restic is fast and uses compression. FreeFileSync was significantly slower at detecting changes and copying modified files.

---

## Vaultwarden

- Self-hosted password manager  
- Passwords never leave my infrastructure  
- Full control and security  

---

## Nextcloud

- Self-hosted file and photo management  
- No need for Google Drive or other cloud services — Nextcloud acts as my personal Google Drive  
- Full control and privacy  

---

## All services run as LXC containers, one service per container

The core principle is that **each service runs in its own LXC container**, ensuring proper isolation.  
If one container stops or fails, **it does not affect the other services**.

**Advantages of LXC compared to virtual machines:**
- **Lower resource usage**: less RAM and CPU required, faster startup
- **Faster deployment**: new containers can be created in minutes
- **Better scalability**: more services can run on a single host
- **Isolation**: failures are contained within individual services

---

## Reverse proxy (Nginx / Traefik) – using local DNS names

- A **key design rule** is that **neither Nginx nor Traefik uses hardcoded IP addresses**, but instead relies on **local DNS hostnames**.
- This ensures that **IP address changes do not require updating multiple configurations** — only the DNS record needs to be changed centrally.
- Benefits of this approach:
  - **Flexible**: IP changes are painless
  - **Clean and readable**: descriptive hostnames instead of fixed IPs

---

← [Back to the Homelab main page](../README_HU.md)
