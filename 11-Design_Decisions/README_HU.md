# Proxmox kisebb (250 GB) SSD-n, VM-ek gyors 1 TB-os M.2 SSD-n külön, szétválasztva

- A Clonezilla mentés csak a 250 GB-os Proxmox SSD-ről szükséges, mivel a VM-eket a Proxmox Backup Server (PBS) menti. Így nem kell az 1 TB-os meghajtót, ami a Proxmoxot és a VM-eket tartalmazza, feleslegesen menteni, ami gyorsabb és kevesebb tárhelyet igényel.
- I/O terhelés szétválasztása: a Proxmox host és a VM-ek is végeznek I/O műveleteket. Ha egy lemezen lennének, a terhelés összeadódna; külön SSD-kkel pedig a műveletek eloszlanak, ami stabilabb és gyorsabb rendszert biztosít.

# FreeFileSync lecserélése Restic-re
  - Az új laptopomról **Restic** segítségével készítek biztonsági mentést a TrueNAS szerverre.
  - Miért Restic:
    - Biztonságos: a véletlen forrásfájl törlés nem veszélyezteti a mentést.
    - Verziózás: akár korábbi állapotok is visszaállíthatók.
    - Hatékony: tömörít, gyors és megbízható mentést biztosít.
  - Lecseréltem a FreeFileSync-et, mivel ott a kétirányú szinkronizáció miatt elveszhettek fájlok, ha hibázok.
