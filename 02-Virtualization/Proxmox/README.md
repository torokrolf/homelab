← [Back to Homelab Home](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Proxmox

---

## VMs and LXCs Running on Proxmox
<img src="https://github.com/user-attachments/assets/e218f011-7896-4dbe-b5e2-0e13861d0909" alt="Image description" width="500"/>

---

## 🖥️ Proxmox Ubuntu VM Template + Cloud-init

**Can be used for LXC templates, but Cloud-init is not supported!**

Since I use most of my VMs with Ubuntu on Proxmox, I created an **Ubuntu VM template** to avoid installing a new OS every time, updating it, or setting up SSH keys manually.  

**Creation process:**  
- Configured the base VM (updates, installed cloud-init)  
- Prepared the VM for conversion to a template:  
  - Deleted SSH keys  
  - Cleared hostname  
  - Enabled DHCP  
- Converted the VM into a template

**Usage:**  
- Simply clone a new VM from the template  
- Use Cloud-init to configure key settings:  
  - Hostname  
  - SSH keys  
  - Network  
  - Domain and DNS server

---

## 🔄 Proxmox 8 → 9 and PBS 3 → 4 Upgrade

I’ve been using the system for a few months, and when Proxmox 9 and PBS 4 were released, I wanted to see if an already configured system could be upgraded smoothly.

- Proxmox **8 → 9** upgrade completed.  
  - On one Proxmox host, upgraded via **in-place upgrade**.  
  - On the other host, installed Proxmox VE 9 via **fresh installation** and restored VMs from **PBS backups**.

- Proxmox Backup Server (**PBS**) also upgraded: **3 → 4**.

---

← [Back to Homelab Home](../README.md)
