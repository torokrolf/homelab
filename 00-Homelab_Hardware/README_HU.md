
# Homelab Hardware
---
<p align="center">
  <img src="https://github.com/user-attachments/assets/e29a96a7-a474-4bb9-acd2-cbe7c00b9538"
       alt="Kép leírása"
       width="700">
</p>

## 🖥️ Számítógépek

### Lenovo ThinkCentre M920q Tiny
**Szerep:** Virtualizációs node (Proxmox VE)

- **CPU:** Intel Core i5-8500T  
- **RAM:** 64 GB  
- **Rendszer meghajtó:** 256 GB SSD (Proxmox)  
- **Adattárolás:**  
  - Külső 1 TB Samsung 870 EVO SSD  
- **Hálózat:**  
  - Intel i350-T2 V1 dual-port (2×1GbE NIC), aminek a beszereléséhez szükséges egy New PCIe x16 Expansion Graphic Card Adapter (Lenovo ThinkCentre 910Q / 910X / M720 / ThinkStation P330 Tiny kompatibilis – 01AJ940)*

---

### Lenovo ThinkCentre M70q Gen 3 Tiny
**Szerep:** Virtualizációs node (Proxmox VE)

- **CPU:** Intel Core i5-12500T  
- **RAM:** 64 GB  
- **Rendszer meghajtó:** 256 GB SSD (Proxmox)  
- **Adattárolás:**  
  - Crucial T500 PRO 1 TB M.2 NVME PCI-E 4.0 x4 
  - Külső 1 TB Samsung 870 EVO SSD  

---

## 🌐 Hálózati eszközök

### TP-Link TL-SG108E
- 8 portos **managed Gigabit switch**
- VLAN támogatás

### TP-Link UE330 (2 db)
**Funkció:**  
- USB → Ethernet + USB port bővítés

**Felhasználás:**
- **M70q Gen 3:**  
  - Internet kapcsolat biztosítása, mivel a belső NIC véletlenszerűen lecsatlakozott, és végleg elvesztette a hálózatot  
  - Külső SSD csatlakoztatása
- **M920q:**  
  - Külső SSD csatlakoztatása

---
## 💾 Külső adattároló házak

### AXAGON EE25-GTR (USB 3.x)
**Felhasználás:**  
- Külső **Samsung 870 EVO SSD-k** háza

**Előnyök / tapasztalat:**
- Az SSD **nem kapcsol ki inaktivitás esetén**
- Meghajtók **folyamatosan elérhetők**
- Stabil működés **Proxmox alatt**
- Megbízható USB–SATA bridge hosszú távú üzemeltetéshez

**Miért fontos:**  
Virtualizációs környezetben (backup, ISO, VM storage) kritikus, hogy a külső meghajtó  
**ne aludjon el és ne dobja el a kapcsolatot**.

---

## 🧠 Tervezési elvek


