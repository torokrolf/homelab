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

- **smb-vm-mount.sh** – Korábban a Proxmox host SMB mountolására használt script, amikor az SMB szolgáltatást egy Proxmox VM biztosította **ugyanazon a hoston**, és a megosztást más VM-ek / LXC-k számára a hoston keresztül kellett továbbadni. A megoldás jelenleg **nem használt**, mivel az SMB szolgáltatás **TrueNAS-re lett migrálva**, és a VM-ek, amikhez mountolom ezt a megosztást, másik Proxmox hoston vannak.



---

← [Vissza a Homelab főoldalra](../README_HU.md)






