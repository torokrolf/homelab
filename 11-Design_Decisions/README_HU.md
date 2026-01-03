# Proxmox kis méretű (250GB) SSD-n a Proxmox, míg a gyors 1TB-os M2 SSD-n a VM/LXC

**Miért így:**
- Clonezilla mentés csak a 250 GB-os host SSD-ről szükséges → gyorsabb, egyszerűbb
- A VM-eket amúgy is a Proxmox Backup Server (PBS) menti → nincs redundáns mentés
- I/O terhelés szétválasztása:
  - Host I/O → SATA SSD
  - VM I/O → M.2 SSD
- Stabilabb és professzionálisabb felépítés

> Ez a felállás egyszerre gyorsítja a mentéseket és csökkenti a lemezterhelést,  
> miközben a virtualizációs környezet optimális marad.
