← [Back to Homelab Home](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# 1. Backup and Recovery

---

## 1.1 📚 Table of Contents

- [Clonezilla](./Clonezilla/)
- [Macrium Reflect](./Macrium_Reflect/)
- [Nextcloud](./Nextcloud/)
- [Proxmox Backup Server](./Proxmox_Backup_Server/)
- [Rclone](./Rclone/)
- [Restic](./Restic/)
- [Veeam Backup & Replication](./Veeam_Backup_Replication/)

---

## 1.2 My Backup Strategy

- Full Proxmox host image with Clonezilla (**block-level backup**)
- VM and LXC backups to Proxmox Backup Server (**block-level incremental backup**)
- Windows laptop system backup with Veeam Backup & Replication Community Edition to SMB share (**block-level incremental backup**)
- Windows and Ubuntu dual-boot machine backup with Macrium Reflect
- Nextcloud file sharing between laptop and phone
- Phone photos backed up to SMB share via FolderSync (**one-way sync**)
- Laptop file sync with FreeFileSync, later replaced by Restic for versioned backup (**file-level backup**)

---

## 1.3 Veeam or Macrium for Dual-Boot Machines?

I use Veeam B&R to back up Linux or Windows with its agent. However, for dual-boot systems:

- The Windows agent and Linux agent cannot run simultaneously
- The agent can only see and back up the currently running OS
- Without the agent, a full disk backup is possible, but Linux filesystems are often not handled properly

For dual-boot machines (e.g., an old laptop with Ubuntu + Windows), Macrium should be used.  

Macrium creates a full disk image:

- It doesn’t care which OS is installed
- It backs up the partition table, bootloader, everything
- Perfect for dual-boot / multi-boot machines
- Boot partitions are also backed up

---

← [Back to Homelab Home](../README.md)
