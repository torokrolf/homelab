# Proxmox kisebb (250 GB) SSD-n, VM-ek gyors 1 TB-os M.2 SSD-n

**Miért választom szét külön SSD-re a Proxmox rendszert és a VM-eket?:**
- A Clonezilla mentés csak a 250 GB-os Proxmox SSD-ről szükséges, mivel a VM-eket a Proxmox Backup Server (PBS) menti. Így nem kell az 1 TB-os Proxmox + VM-et tartalmazó meghajtót feleslegesen menteni, ami gyorsabb és kevesebb tárhelyet igényel.
- I/O terhelés szétválasztása: a Proxmox host és a VM-ek is végeznek I/O műveleteket. Ha egy lemezen lennének, a terhelés összeadódna, külön SSD-kkel pedig a műveletek eloszlanak, ami stabilabb és gyorsabb rendszert biztosít.
