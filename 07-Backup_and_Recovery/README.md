← [Back to the Homelab main page](../README_HU.md)

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

## 1.2 My Applied Backup Strategy
 
- Full Proxmox host image with Clonezilla (**block-level backup**)
- VM and LXC backups to Proxmox Backup Server (**block-level incremental backup**)  
- Windows laptop system backup with Veeam Backup & Replication Community Edition to an SMB share (**block-level incremental backup**)
- Windows and Ubuntu dual-boot machine backup with Macrium Reflect
- Nextcloud file sharing between laptop and phone
- One-way photo sync from phone to SMB share using FolderSync (**one-way synchronization**)
- Laptop file sync with FreeFileSync, later replaced by Restic for versioned backups (**file-level backup**)

---

## 1.3 Veeam or Macrium for backing up a dual-boot machine?

I use Veeam B&R to back up either Linux or Windows using an agent. However, I do not use it for dual-boot systems because:

- The Windows agent and Linux agent cannot run at the same time
- It only sees and backs up the currently running operating system

For dual-boot machines (e.g., an old laptop with Ubuntu + Windows), Macrium should be used.

Macrium creates a full disk image:

- It does not care what operating system is on the disk
- It backs up the partition table, bootloader, and everything else
- Perfect for dual-boot / multi-boot machines

---

← [Back to the Homelab main page](../README_HU.md)
