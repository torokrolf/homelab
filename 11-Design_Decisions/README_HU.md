# Proxmox kis méretű (250GB) SSD-n a Proxmox, míg a VM-ek a gyors 1TB-os M2 SSD-n

**Miért így:**
- Így a Clonezilla mentés csak a 250 GB-os Proxmox-ot tartalmazó SSD-ről szükséges, hiszen felesleges a VM rendszerekről mentést készíteni, ugyanis a Proxmox Backup Server (PBS) menti őket. Ezáltal nem 1TB-os csak 250GB-os mentések készülnek, amivel idős és helyet spórolok.
- I/O terhelés szétválasztása: Proxmoxnak és a VM-nek is van I/O művelete, ha egy SSD-n vannak, akkor nem oszlik meg a terhelés, ha külön SSD-n vannak, akkor megoszlik és gyorsabb lesz
