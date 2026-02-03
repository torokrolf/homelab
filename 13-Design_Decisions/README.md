← [Back to the Homelab main page](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Design Decisions and Rationale

Here I explain why I chose certain technologies and architectures.

---

# Proxmox and VMs together on a 1TB M.2 SSD, later separating: Proxmox on 250GB SSD and VMs on fast 1TB M.2 SSD

- **Space saving**: This way, Clonezilla backup only needs to cover the 250GB SSD containing Proxmox. VMs are backed up by the Proxmox Backup Server (PBS), so no Clonezilla backup is needed for them. Result: faster backups that require less storage.
- **I/O load separation**: Both the Proxmox host and the VMs perform I/O operations. If they were on the same disk, the load would accumulate; with separate SSDs, operations are distributed, providing a more stable and faster system.

# Replacing FreeFileSync with Restic

- Important files on my new laptop are backed up to the TrueNAS server using **Restic**.
- Why Restic:
  - **Safe**: If a source file is accidentally deleted, Restic allows restoring it. With FreeFileSync, accidental sync after deletion may result in permanent loss.
  - **Versioning**: Previous states of files can be restored.
  - **Efficient**: Compressed and fast; FreeFileSync checked changes and copied files much slower.

# Nextcloud

- Self-hosted file and photo management  
- No need for Google Drive or other cloud; Nextcloud is my personal cloud
- Full control and security  

# Vaultwarden

- Self-hosted password management  
- Passwords never leave your network  
- Full control and security  

# Running all services I can in separate LXC containers

The main goal is that **each service runs in its own LXC**, so they are isolated: if one container stops, it **does not affect other services**.

**Advantages of LXC over VMs:**
- **Lower resource usage**: less RAM and CPU required, faster startup
- **Faster deployment**: new containers can be created in minutes
- **Scalability**: more containers can fit on a host than VMs
- **Isolation**: a failing or stopped service does not bring down others

---

← [Back to the Homelab main page](../README_HU.md)
