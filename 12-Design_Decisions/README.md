← [Back to Homelab Home](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Proxmox on smaller (250 GB) SSD, VMs on fast separate 1 TB M.2 SSD

- **Space saving**: Only the 250 GB Proxmox SSD needs to be backed up with Clonezilla, as the VMs are backed up by the Proxmox Backup Server (PBS). This avoids backing up the 1 TB drive that contains Proxmox and all VMs, which is faster and uses less storage.  
- **I/O load separation**: Both the Proxmox host and the VMs perform I/O operations. If they were on the same drive, the load would add up. With separate SSDs, operations are spread out, providing a more stable and faster system.

---

# Replacing FreeFileSync with Restic

- I now back up important files from my new laptop to the TrueNAS server using **Restic**.  
- Why Restic:
  - **Safe**: With Restic, accidentally deleted source files can be restored. With FreeFileSync, if a source file is deleted and synced by mistake, it cannot be recovered.  
  - **Versioning**: Previous versions of files can be restored.  
  - **Efficient**: Compression and fast syncing; FreeFileSync was slower at checking changes and copying modified files.

---

# Vaultwarden

- Self-hosted password manager  
- Passwords do not leave the network  
- Full control and security  

---

# Nextcloud

- Self-hosted file and photo management  
- No need for Google Drive / other cloud; Nextcloud is my personal cloud  
- Full control and security  

---

# Running all services in separate LXC containers

The main goal is to **run each service in its own LXC**, keeping them isolated: if one container stops, it **does not affect the other services**.

**Advantages of LXC over full VMs:**
- **Lower resource usage**: less RAM and CPU required, faster startup  
- **Faster deployment**: new containers can be created in minutes  
- **Scalability**: more containers fit on a single host compared to VMs  
- **Isolation**: a faulty or stopped service does not bring down the others

---

← [Back to Homelab Home](../README.md)

