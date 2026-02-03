← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# 1. Backup and Recovery

---

## 1.1 📚 Tartalomjegyzék

- [Clonezilla](./Clonezilla/)
- [Macrium Reflect](./Macrium_Reflect/)
- [Nextcloud](./Nextcloud/)
- [Proxmox Backup Server](./Proxmox_Backup_Server/)
- [Rclone](./Rclone/)
- [Restic](./Restic/)
- [Veeam Backup & Replication](./Veeam_Backup_Replication/)

---

## 1.2 Alkalmazott mentési stratégiám
 
- Teljes Proxmox host image Clonezillával (**blokkszintű mentés**)
- VM és LXC mentések Proxmox Backup Serverre (**blokkszintű inkrementális mentés**)
- Windows-os laptop rendszermentése Veeam Backup & Replication Community Editionnel SMB megosztásba (**blokkszintű inkrementális mentés**)
- Windows és Ubuntu dualboot gép mentése Macrium Reflect-el
- Nextcloud fájlmegosztás laptop és telefon között
- Telefonon lévő képek FolderSync-kel SMB megosztásba mentése (**egyirányú szinkronizálás**)
- Laptop fájl szinkron FreeFileSync-kel, később Restic-re cserélve verziózott mentés miatt (**fájlszintű mentés**)

---

## 1.3 Veeam vagy Macrium dualbootos gép mentéséhez?

Veeam B&R-t használok hogy Linuxot vagy Windowst mentsek vele agenttel. Azonban dualbootos rendszernél nem használom, mert:

- Windows agent és Linux agent nem tud egyszerre futni
- mindig csak az éppen futó rendszert látja és menti

Dualbootos gépnél (pl régi laptop ubuntu + windows) Macriumot kell használni.

A Macrium teljes disk image-et csinál:

- nem érdekli milyen OS van rajta
- menti a partíciós táblát, bootloadert, mindent
- tökéletes dualboot / multiboot gépre

---

← [Vissza a Homelab főoldalra](../README_HU.md)
