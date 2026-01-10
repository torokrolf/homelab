← [Back to Homelab Home](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Clonezilla Backup for Proxmox Host

Goal: **Automated monthly backup of the Proxmox system (without VMs) to an external HDD**.

---

## 💻 Method

- Using **Clonezilla** to back up the Proxmox host without VMs, while VMs are backed up separately by the **Proxmox Backup Server**.

---

## ⚙️ Unattended Preseed Clonezilla ISO with Custom Menu

- The backup ISO is on an **external USB drive** connected to the machine, which writes to the **external backup HDD**.  
- Grub entry created on the host for the Clonezilla ISO.

---

← [Back to Homelab Home](../README.md)
