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

## Alkalmazott mentési stratégiám
 
| Célpont / Eszköz | Alkalmazott Szoftver | Mentési technológia | Megjegyzés |
| :--- | :--- | :--- | :--- |
| **Proxmox Host** | Clonezilla | Blokkszintű Image | Teljes rendszermentés (Bare-metal recovery) |
| **VM & LXC** | Proxmox Backup Server | Blokkszintű Inkrementális | Chunk-alapú deduplikáció és verziózás |
| **Windows Laptop** | Veeam Community Ed. | Blokkszintű Inkrementális | Teljes rendszermentés SMB megosztásba |
| **Dualboot PC** | Macrium Reflect | Blokkszintű Image | Windows és Ubuntu partíciók együttes mentése |
| **Mobil fotók** | FolderSync (Android) | Egyirányú szinkronizálás | Fotók automatikus mentése SMB tárolóra |
| **Laptop adatok** | Restic (korábban FreeFileSync) | Fájlszintű Deduplikált | Verziózott, titkosított és tömörített mentés |
| **Fájlmegosztás** | Nextcloud | Valós idejű szinkron | Eszközök közötti adatkapcsolat (Laptop/Mobil) |

---

## Veeam vagy Macrium dualbootos gép mentéséhez?

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

### 1.4.1 Nextcloud előnye

- Self-hosted fájl- és képkezelés  
- Nem szükséges Google Drive / más felhő, Nextcloud a saját Google Drive-om
- Teljes kontroll és biztonság  

---
### 1.4.2 Hibák
### Hibák - Trusted Domains / Whitelist

Nextcloud csak azokat a címeket engedi, amelyek szerepelnek a `config.php` fájlban a trusted_domains listában.

- Ha egy cím nincs whitelistelve, IP-n működhet, DNS néven nem (vagy fordítva), Nextcloud untrusted domain hibát ad
- Ha **NGINX reverse proxy-n** keresztül (pl. `nextcloud.trkrolf.com`) érem el, a **DNS nevet hozzá kell adni** a whitelisthez.
- Ha **lokális DNS névvel** (pl. `nextcloud.otthoni.local`) vagy **IP címmel** szeretném elérni, azokat is külön fel kell venni.
- **Tailscale használatakor** a szerver **Tailscale IP-jét** szintén hozzá kell adni, különben nem érhető el távolról.

---

<a name="pbs"></a>
## 1.5 Proxmox Backup Server

---

<a name="rclone"></a>
## 1.6 Rclone

---

<a name="restic"></a>
## 1.7 Restic

---

<a name="veeam"></a>
## 1.8 Veeam Backup & Replication

---

← [Vissza a Homelab főoldalra](../README_HU.md)










