← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# 📚 Tartalomjegyzék

- [Clonezilla](./Clonezilla/README_HU.md)
- [Macrium Reflect](./Macrium_Reflect/README_HU.md)
- [Nextcloud](./Nextcloud/README_HU.md)
- [Proxmox Backup Server](./Proxmox_Backup_Server/README_HU.md)
- [Rclone](./Rclone/README_HU.md)
- [Restic](./Restic/README_HU.md)
- [Veeam Backup & Replication](./Veeam_Backup_Replication/README_HU.md)

---

# Megvalósított mentési megoldások
 
- **Proxmox host mentés**
  - A Proxmox rendszer blokkszintű mentése **Clonezilla** segítségével.
  - Automatizálás **preseed** konfigurációval.
- **Virtuális környezet mentése**
  - VM-ek és LXC-k mentése egy virtualizált **Proxmox Backup Serverre**.
- **Kliens oldali mentések**
  - Windows laptopom mentése **Veeam Backup & Replication Community Edition** használatával SMB megosztásba.
  - **Személyes fájlok mentése és szinkronizációja**
  - **Nextcloud**: self-hosted fájlmegosztás laptop és telefon között.
  - **Telefon**: fényképek egyirányú szinkronizálása homelabra **FolderSync** segítségével.
  - **Laptop**: fájlok szinkronizálása homelabra **FreeFileSync** használatával, amit később **Restic**-re cseréltem.

---

← [Vissza a Homelab főoldalra](../README_HU.md)












