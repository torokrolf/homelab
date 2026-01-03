# Proxmox kis méretű (250GB) SSD-n a Proxmox, míg a gyors 1TB-os M2 SSD-n a VM

**Miért így:**
- Így a Clonezilla mentés csak a 250 GB-os host SSD-ről szükséges, hiszen felesleges a VM rendszerekről mentéstkészíteni, ugyanis a Proxmox Backup Server (PBS) menti őket
- I/O terhelés szétválasztása: Proxmoxnak és a VM-nek is van I/O művelete, ha egy SSD-n vannak, akkor nem oszlik meg a terhelés, ha külön SSD-n vannak, akkor megoszlik és gyorsabb lesz
