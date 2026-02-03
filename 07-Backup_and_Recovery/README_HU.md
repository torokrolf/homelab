← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# 1. Backup and Recovery

---

## 1.1 📚 Tartalomjegyzék

- [1.2 Clonezilla](#clonezilla)
- [1.3 Macrium Reflect](#macriumreflect)
- [1.4 Nextcloud](#nextcloud)
- [1.5 Proxmox Backup Server](#pbs)
- [1.6 Rclone](#rclone)
- [1.7 Restic](#restic)
- [1.8 Veeam Backup & Replication](#veeam)

---

### 1.1.2 Alkalmazott mentési stratégiám
 
- Teljes Proxmox host image Clonezillával (**blokkszintű mentés**)
- VM és LXC mentések Proxmox Backup Serverre (**blokkszintű inkrementális mentés**)
- Windows-os laptop rendszermentése Veeam Backup & Replication Community Editionnel SMB megosztásba (**blokkszintű inkrementális mentés**)
- Windows és Ubuntu dualboot gép mentése Macrium Reflect-el
- Nextcloud fájlmegosztás laptop és telefon között
- Telefonon lévő képek FolderSync-kel SMB megosztásba mentése (**egyirányú szinkronizálás**)
- Laptop fájl szinkron FreeFileSync-kel, később Restic-re cserélve verziózott mentés miatt (**fájlszintű mentés**)

---

### 1.1.3 Veeam vagy Macrium dualbootos gép mentéséhez?

Veeam B&R-t használok hogy Linuxot vagy Windowst mentsek vele agenttel. Azonban dualbootos rendszernél nem használom, mert:

- Windows agent és Linux agent nem tud egyszerre futni
- az agent mindig csak az éppen futó rendszert látja és menti
- agent nélkül ugyan lehetne teljes lemezről mentést csinálni, de a linuxos fájlrendszert sokszor nem megfelelően kezeli

Dualbootos gépnél (pl régi laptop ubuntu + windows) Macriumot kell használni.

A Macrium teljes disk image-et csinál:

- nem érdekli milyen OS van rajta
- menti a partíciós táblát, bootloadert, mindent
- tökéletes dualboot / multiboot gépre
- boot partíciókat is menti

---

<a name="clonezilla"></a>
## 1.2 Clonezilla

---

<a name="macriumreflect"></a>
## 1.3 Macrium Reflect

---

<a name="nextcloud"></a>
## 1.4 Nextcloud

---

<img width="2542" height="656" alt="kép" src="https://github.com/user-attachments/assets/ed38c604-a50b-4b80-a4b4-331a7696582a" />

---

## Nextcloud előnye

- Self-hosted fájl- és képkezelés  
- Nem szükséges Google Drive / más felhő, Nextcloud a saját Google Drive-om
- Teljes kontroll és biztonság  

---
## Hibák
### Hibák - Trusted Domains / Whitelist

Nextcloud csak azokat a címeket engedi, amelyek szerepelnek a `config.php` fájlban a `trusted_domains` listában.

- Ha **NGINX reverse proxy-n** keresztül (pl. `nextcloud.trkrolf.com`) érem el, a **DNS nevet hozzá kell adni** a whitelisthez.
- Ha **lokális DNS névvel** (pl. `nextcloud.otthoni.local`) vagy **IP címmel** szeretném elérni, azokat is külön fel kell venni.
- **Tailscale használatakor** a szerver **Tailscale IP-jét** szintén hozzá kell adni, különben nem érhető el távolról.

📌 Ha egy cím nincs whitelistelve:
- IP-n működhet, DNS néven nem (vagy fordítva)
- Nextcloud „untrusted domain” hibát ad

---
---

← [Vissza a Homelab főoldalra](../README_HU.md)







