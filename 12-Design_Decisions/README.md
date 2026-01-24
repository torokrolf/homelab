← [Back to the Homelab main page](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Hungarian](README_HU.md)

---

## Design decisions and reasoning

Here I explain why I chose certain technologies and architectures.

---
# Proxmox on a smaller (250 GB) SSD, VMs on a separate fast 1 TB M.2 SSD

- **Space saving**: Clonezilla backups are only required for the 250 GB Proxmox SSD, since virtual machines are backed up using Proxmox Backup Server (PBS). This means the 1 TB drive that stores the VMs does not need to be backed up unnecessarily, resulting in faster backups and reduced storage usage.
- **I/O separation**: Both the Proxmox host and the virtual machines perform I/O operations. If they were on the same disk, the load would accumulate. Using separate SSDs distributes the workload, providing a more stable and faster system.

# Replacing FreeFileSync with Restic

- Important files on my new laptop are backed up to the TrueNAS server using **Restic**.
- Why Restic:
  - **Secure**: With Restic, accidentally deleted source files can be restored. With FreeFileSync, if I accidentally synchronize after deleting a source file, recovery is not possible.
  - **Versioning**: Previous states can also be restored.
  - **Efficient**: Restic uses compression and is fast. FreeFileSync was much slower at detecting changes and copying modified files.

# Vaultwarden

- Self-hosted password management  
- Passwords never leave my infrastructure  
- Full control and security  

# Nextcloud

- Self-hosted file and photo management  
- No need for Google Drive or other cloud services — Nextcloud is my own Google Drive  
- Full control and security  

---
# All services run as LXC containers, one service per container

The main goal is that **each service runs in its own LXC container**, ensuring isolation.  
If one container stops, it **does not affect the other services**.

**Advantages of using LXC compared to virtual machines:**
- **Lower resource usage**: requires less RAM and CPU, faster startup
- **Faster deployment**: new containers can be created in minutes
- **Scalability**: more containers can run on a single host than VMs
- **Isolation**: a faulty or stopped service does not bring down the others

---

← [Back to the Homelab main page](../README_HU.md)
