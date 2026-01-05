← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Clonezilla Backup for Proxmox Host

A cél: **Proxmox rendszer (VM-ek nélkül) automatizált havi mentése külső HDD-re**.

---

## 💻 Módszer

- **Clonezilla** használata a Proxmox host mentésére VM-ek nélkül, a VM-eket **Proxmox Backup Server** menti külön.  

---

## ⚙️ Unattended preseed Clonezilla ISO saját menüvel  

- A mentési ISO **külső pendrive-on** van, ami a géphez csatlakozik, és a **külső mentési HDD-re** ír.  
- Grub entry készítve a gépen a Clonezilla ISO-hoz.

---

← [Vissza a Homelab főoldalra](../README_HU.md)
