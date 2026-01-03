
## Hardware Overview – Homelab Infrastructure
---
<img src="https://github.com/user-attachments/assets/e29a96a7-a474-4bb9-acd2-cbe7c00b9538" alt="Kép leírása" width="700"/>

## 🖥️ Computer Nodes

### Lenovo ThinkCentre M920q Tiny
**Szerep:** Virtualizációs node (Proxmox VE)

- **CPU:** Intel Core i5-8500T  
- **RAM:** 64 GB  
- **Rendszer meghajtó:** 256 GB SSD (Proxmox)  
- **Adattárolás:**  
  - Külső 1 TB Samsung 870 EVO SSD  
- **Hálózat:**  
  - Intel i350-T v1 dual-port (2×1GbE NIC), **New PCIe x16 Expansion Graphic Card Adapter**  
  *(Lenovo ThinkCentre 910Q / 910X / M720 / ThinkStation P330 Tiny kompatibilis – 01AJ940)*

**Cél:**  
Lehetővé teszi **low-profile PCIe hálózati kártya (Intel i350-T)** beépítését Tiny form factor gépbe,  
így biztosítva a **stabil, dedikált hálózati interfészeket** virtualizációs és tűzfalas felhasználásra.

---

### Lenovo ThinkCentre M70q Gen 3 Tiny
**Szerep:** Virtualizációs node (Proxmox VE)

- **CPU:** Intel Core i5-12500T  
- **RAM:** 64 GB  
- **Rendszer meghajtó:** 256 GB SSD (Proxmox)  
- **Adattárolás:**  
  - Belső 1 TB M.2 SSD  
  - Külső 1 TB Samsung 870 EVO SSD  
- **Hálózat & USB bővítés:**  
  - TP-Link UE330 (USB → Ethernet + USB)

---

## 🌐 Network Equipment

### TP-Link TL-SG108E
- 8 portos **managed Gigabit switch**
- VLAN támogatás
- Homelab core switch szerep
- Hálózati szeparáció és tesztelés

---

## 🔌 USB Network & Storage Adapters

### TP-Link UE330 (2 db)
**Funkció:**  
- USB → Ethernet + USB port bővítés

**Felhasználás:**
- **M70q Gen 3:**  
  - Internet kapcsolat  
  - Külső SSD csatlakoztatása
- **M920q:**  
  - Külső SSD csatlakoztatása

---

## 💾 External Storage Enclosures

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
- Külön rendszer- és adatmeghajtók
- Skálázható virtualizációs infrastruktúra
- Tiny form factor gépek vállalati felhasználása
- Dedikált hálózati interfészek, ahol szükséges
- Dokumentált, átlátható felépítés

---

## 🎯 Mit mutat ez a hardver setup?
- Tudatos hardverválasztás virtualizációhoz
- Proxmox-ra optimalizált infrastruktúra
- Tiny PC-k bővítése vállalati szintű NIC-kel
- Stabil külső storage megoldások
- Homelab környezetben szerzett **valós üzemeltetési tapasztalat**



