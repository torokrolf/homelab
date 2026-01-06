← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)
# Nextcloud

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

← [Vissza a Homelab főoldalra](../README_HU.md)








