← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Proxmox kisebb (250 GB) SSD-n, VM-ek gyors 1 TB-os M.2 SSD-n külön, szétválasztva

- **Helyspórolás**: A Clonezilla mentés csak a 250 GB-os Proxmox SSD-ről szükséges, mivel a VM-eket a Proxmox Backup Server (PBS) menti. Így nem kell az 1 TB-os meghajtót, ami a Proxmoxot és a VM-eket tartalmazza, feleslegesen menteni, ami gyorsabb és kevesebb tárhelyet igényel.
- **I/O terhelés szétválasztása**: a Proxmox host és a VM-ek is végeznek I/O műveleteket. Ha egy lemezen lennének, a terhelés összeadódna; külön SSD-kkel pedig a műveletek eloszlanak, ami stabilabb és gyorsabb rendszert biztosít.

# FreeFileSync lecserélése Restic-re

  - Az új laptopomon lévő fontos fájlaimról **Restic** segítségével készítek biztonsági mentést a TrueNAS szerverre.
  - Miért Restic:
    - **Biztonságos**: Restic-nél a véletlen forrásfájl törlés esetén visszaállítható a törölt fájl, míg FreeFileSync-nél, ha a forrásfájl törlése után véletlen szinkronizálok, akkor nem tudom visszaállítani a fájlt.
    - **Verziózás**: akár korábbi állapotok is visszaállíthatók.
    - **Hatékony**: tömörít, gyors, FreeFileSync sokkal lassabban ellenőrizte le a változásokat és lassabban másolta  a megváltozott fájlokat.

# Vaultwarden

- Self-hosted jelszókezelés  
- Jelszavak nem kerülnek ki az internetre  
- Teljes kontroll és biztonság  

# Nextcloud

- Self-hosted fájl- és képkezelés  
- Nem szükséges Google Drive / más felhő, Nextcloud a saját Google Drive-om
- Teljes kontroll és biztonság  

---
# Szerverek

A homelabban a szolgáltatásokat főként **LXC konténerekben** hozom létre, mert ezek **kevesebb erőforrást igényelnek**, mint a teljes virtuális gépek (VM-ek), miközben gyorsan és rugalmasan telepíthetők.

**Előnyök LXC használatával VM-ekhez képest:**
- **Kisebb erőforrásigény**: kevesebb RAM és CPU szükséges, gyorsabb indítás
- **Gyorsabb deployment**: új konténerek percek alatt létrehozhatók
- **Egyszerűbb frissítés és karbantartás**: a host rendszeren futnak, így könnyebb menedzselni
- **Hálózati rugalmasság**: könnyebb belső hálózati és bridge konfigurációk
- **Skálázhatóság**: több konténer fér el egy hoston, mint VM-ekből ugyanannyi

VM-ekhez képest hátránya, hogy a **konténerek kevésbé izoláltak**, így a host rendszer biztonságára jobban kell figyelni.

---

← [Vissza a Homelab főoldalra](../README_HU.md)
