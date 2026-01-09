← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---
# Scripts
---
## pfsense

- **ddns-force-update.sh** – pfSense tűzfalon futó script, amely IP változás esetén manuálisan triggereli a DDNS frissítést
---

## Powershell

- **restic-backup-and-shutdown.ps1** – Restic backup majd automatikus leállítás
---

## Proxmox

- **smb-vm-mount.sh** – Régebben a Proxmox hosthoz ezzel mountoltam  egy SMB megosztást, és az megosztást ugyanezen a Proxmox hoston futó VM szolgáltatta, és a versenyhelyzet miatt nem mountolta, ugyanis ahogy elindult a Proxmox, máris mountolt volna, csakhogy nem tudta még mountolni, hiszen a VM még nem állt fel. Ma már nem használatos, mert a TrueNAS külön Proxmox hoston szolgáltatja a megosztást a VM-eknek.
- **smb-vm-mount.service** – systemd service, ami egyszeri futtatással elindítja a mount scriptet (**smb-vm-mount.sh**) a boot után

---

## qBittorrent + NFS (TrueNAS)

- **nfs_qbittorrent.sh** – Script, ami folyamatosan ellenőrzi, hogy a TrueNAS NFS megosztás elérhető-e. Ha igen, mountolja a megosztást és elindítja a **qbittorrent-nox** szolgáltatást; ha a megosztás eltűnik, leállítja a qBittorrentet és unmountolja a megosztást.  
- **nfs_qbittorrent.service** – systemd service, ami a **nfs_qbittorrent.sh**  scriptet automatikusan indítja a boot során és folyamatosan futtatja. Gondoskodik arról, hogy a qBittorrent csak akkor fusson, ha a NAS elérhető.

---

## Termux / Android

- **toggle_pihole_ssh.sh** – Termux alatt futó Bash script, amely SSH-n keresztül kapcsolja ki- vagy be a Pi-hole-t. Telefonról gyorsan használható, ha egy képtalálatra kattintva a weboldal nem jön be a Pi-hole blokkolás miatt. A script automatikusan ellenőrzi az aktuális állapotot, majd ennek megfelelően engedélyezi vagy tiltja a Pi-hole-t, és értesítést (toast) küld az Androidon.

---

← [Vissza a Homelab főoldalra](../README_HU.md)












