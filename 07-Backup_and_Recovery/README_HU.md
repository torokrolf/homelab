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
 
- **Proxmox host mentés**
  - A Proxmox rendszer blokkszintű mentése **Clonezilla** segítségével.
  - Automatizálás **preseed** konfigurációval.
- **Virtuális környezet mentése**
  - VM-ek és LXC-k mentése egy virtualizált **Proxmox Backup Serverre**.
- **Kliens oldali mentések**
  - Windows laptopom mentése **Veeam Backup & Replication Community Edition** használatával SMB megosztásba.



