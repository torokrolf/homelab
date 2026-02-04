← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Scripts
---

## pfSense

- **[ddns-force-update.sh](./pfsense/ddns-force-update.sh)** – pfSense tűzfalon futó script, amely IP változás esetén manuálisan triggereli a DDNS frissítést.

---

## Powershell

- **[restic-backup-and-shutdown.ps1](./windows/restic-backup-and-shutdown.ps1)** – Restic backup készítése, majd automatikus leállítás.

---

## qBittorrent + NFS (TrueNAS)

- **[nfs_qbittorrent.sh](./qBittorrent/nfs_qbittorrent.sh)** – Script, ami folyamatosan ellenőrzi, hogy a TrueNAS NFS megosztás elérhető-e. Ha igen, mountolja a megosztást és elindítja a **qbittorrent-nox** szolgáltatást; ha a megosztás eltűnik, leállítja a qBittorrentet és unmountolja a megosztást.  
- **[nfs_qbittorrent.service](./qBittorrent/nfs_qbittorrent.service)** – systemd service, amely automatikusan indítja a **nfs_qbittorrent.sh** scriptet a boot során és folyamatosan futtatja, így a qBittorrent csak akkor fut, ha a NAS elérhető.

---

## Termux / Android

- **[toggle_pihole_ssh.sh](./Android/toggle_pihole_ssh.sh)** – Termux alatt futó Bash script, amely SSH-n keresztül kapcsolja ki vagy be a Pi-hole-t. Gyorsan használható telefonról, ha egy weboldal blokkolva van a Pi-hole miatt; a script ellenőrzi az aktuális állapotot, majd ennek megfelelően engedélyezi vagy tiltja a Pi-hole-t, és toast értesítést küld az Androidon.

---

← [Vissza a Homelab főoldalra](../README_HU.md)
