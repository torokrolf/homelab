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

← [Vissza a Homelab főoldalra](../README_HU.md)








