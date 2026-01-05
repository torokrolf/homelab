← [Back to Homelab Overview](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---


# Homelab Hardware
---
<p align="center">
  <img src="https://github.com/user-attachments/assets/e29a96a7-a474-4bb9-acd2-cbe7c00b9538"
       alt="Image description"
       width="700">
</p>

## 🖥️ Computers

### Lenovo ThinkCentre M920q Tiny
**Role:** Virtualization node (Proxmox VE)

- **CPU:** Intel Core i5-8500T  
- **RAM:** 64 GB  
- **System drive:** 256 GB SSD (Proxmox)  
- **Storage:**  
  - External 1 TB Samsung 870 EVO SSD (for Proxmox Backup Server)
  - External 1 TB Samsung 870 EVO SSD (for TrueNAS)
- **Network:**  
  - Intel i350-T2 V1 dual-port (2×1GbE NIC), requiring a New PCIe x16 Expansion Graphic Card Adapter for installation (compatible with Lenovo ThinkCentre 910Q / 910X / M720 / ThinkStation P330 Tiny – 01AJ940)*

---

### Lenovo ThinkCentre M70q Gen 3 Tiny
**Role:** Virtualization node (Proxmox VE)

- **CPU:** Intel Core i5-12500T  
- **RAM:** 64 GB  
- **System drive:** 256 GB SSD (Proxmox)  
- **Storage:**  
  - Crucial T500 PRO 1 TB M.2 NVME PCI-E 4.0 x4 

---

## 🌐 Network Devices

### TP-Link TL-SG108E
- 8-port **managed Gigabit switch**
- VLAN support

### TP-Link UE330 (2 pcs)
**Function:**  
- USB → Ethernet + USB port expansion

**Usage:**
- **M70q Gen 3:**  
  - Provides Internet connection, because the internal NIC randomly disconnected and permanently lost network  
  - Connect external SSD
- **M920q:**  
  - Connect external SSD

---
## 💾 External Storage Enclosures

### AXAGON EE25-GTR (USB 3.x)
**Usage:**  
- Housing for external **Samsung 870 EVO SSDs**

**Advantages / experience:**
- The SSD **does not power down when inactive**
- Drives are **continuously accessible**
- Stable operation **under Proxmox**

**Why important:**  
In a virtualization environment (backup, ISO, VM storage), it is critical that the external drive  
**does not go to sleep and does not drop the connection**.
