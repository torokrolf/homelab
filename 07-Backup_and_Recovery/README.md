← [Back to Homelab Home](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# 1. Backup and Recovery

---

## 1.1 📚 Table of Contents

- [1.2 Clonezilla](#clonezilla)
- [1.3 Macrium Reflect](#macriumreflect)
- [1.4 Nextcloud](#nextcloud)
- [1.5 Proxmox Backup Server](#pbs)
- [1.6 Rclone](#rclone)
- [1.7 Restic](#restic)
- [1.8 Veeam Backup & Replication](#veeam)

---

## My Backup Strategy

| Target / Device | Software Used | Backup Technology | Remarks |
| :--- | :--- | :--- | :--- |
| **Proxmox Host** | Clonezilla | Block-level Image | Full system backup (Bare-metal recovery) |
| **VM & LXC** | Proxmox Backup Server | Block-level Incremental | Chunk-based deduplication and versioning |
| **Windows Laptop** | Veeam Community Ed. | Block-level Incremental | Full system backup to SMB share |
| **Dualboot PC** | Macrium Reflect | Block-level Image | Combined Windows and Ubuntu partition backup |
| **Mobile Photos** | FolderSync (Android) | One-way Sync | Automatic photo upload to SMB storage |
| **Laptop Data** | Restic (prev. FreeFileSync) | File-level Deduplicated | Versioned, encrypted, and compressed backup |
| **File Sharing** | Nextcloud | Real-time Sync | Cross-device data sync (Laptop/Mobile) |

---

## Veeam or Macrium for Dual-Boot Machines?

I use Veeam B&R to back up Linux or Windows with its agent. However, for dual-boot systems:

- Windows agent and Linux agent cannot run simultaneously  
- The agent only sees and backs up the currently running OS  
- Without the agent, a full disk backup is possible, but Linux filesystems are often not handled properly  

For dual-boot machines (e.g., an old laptop with Ubuntu + Windows), Macrium should be used.  

Macrium creates a full disk image:

- It doesn’t care which OS is installed  
- Backs up the partition table, bootloader, everything  
- Perfect for dual-boot / multi-boot machines  
- Boot partitions are also backed up  

---

<a name="clonezilla"></a>
## 1.2 Clonezilla

---

<a name="macriumreflect"></a>
## 1.3 Macrium Reflect

---

<a name="nextcloud"></a>
## 1.4 Nextcloud

---

<img width="2542" height="656" alt="image" src="https://github.com/user-attachments/assets/ed38c604-a50b-4b80-a4b4-331a7696582a" />

---

### 1.4.1 Advantages of Nextcloud

- Self-hosted file and photo management  
- No need for Google Drive / other cloud services; Nextcloud is my own personal cloud  
- Full control and security  

---

### 1.4.2 Issues
### Issues – Trusted Domains / Whitelist

Nextcloud only allows access from addresses listed in the `config.php` file under the `trusted_domains` list.

- If an address is not whitelisted, it may work via IP but not DNS (or vice versa), and Nextcloud will give an untrusted domain error  
- If accessed through an **NGINX reverse proxy** (e.g., `nextcloud.trkrolf.com`), the **DNS name must be added** to the whitelist  
- If using a **local DNS name** (e.g., `nextcloud.home.local`) or an **IP address**, these must also be added separately  
- **When using Tailscale**, the server’s **Tailscale IP** must also be added; otherwise, remote access will not work  

---

<a name="pbs"></a>
## 1.5 Proxmox Backup Server

---

<a name="rclone"></a>
## 1.6 Rclone

---

<a name="restic"></a>
## 1.7 Restic

---

<a name="veeam"></a>
## 1.8 Veeam Backup & Replication

---

← [Back to Homelab Home](../README.md)

