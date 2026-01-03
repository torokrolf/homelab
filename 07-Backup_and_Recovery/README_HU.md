# Mentés és helyreállítás

## Használt eszközök
- Proxmox Backup Server
- Clonezilla
- Rclone
- Nextcloud
- FreeFileSync
- Restic
- Veeam Backup & Replication Community Edition
- Macrium Reflect

## Megvalósított mentési megoldások
> A mentési megoldások jelenleg az alap infrastruktúra és kliensgépek biztonságos visszaállíthatóságát szolgálják; a mentések és retention policy-k későbbi finomhangolása tervben van.
> 
- **Proxmox host mentés**
  - A Proxmox rendszer blokkszintű mentése **Clonezilla** segítségével.
  - Automatizálás **preseed** konfigurációval.
- **Virtuális környezet mentése**
  - VM-ek és LXC-k mentése egy virtualizált **Proxmox Backup Serverre**.
- **Kliens oldali mentések**
  - Laptop mentése **Veeam Backup & Replication Community Edition** használatával SMB megosztásra.

