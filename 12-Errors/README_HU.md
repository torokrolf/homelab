# Errors

## DNS névfeloldási probléma internet nélkül---megoldás DNS override

**Probléma**:
- A `*.trkrolf.com` (pl. `zabbix.trkrolf.com`) publikus domain, a Cloudflare nameserverre irányult, ami a 192.168.2.202 Nginx IP-t adta vissza.
- Ha a homelabnak **nem volt internetkapcsolata**, a név nem oldódott fel, mert a publikus DNS nem volt elérhető.

**Megoldás**:
- **DNS override / lokális BIND9 DNS**: a `*.trkrolf.com` lekérdezéseket a helyi DNS szerver kezeli.
- Így internet nélkül is mindig a **192.168.2.202 Nginx IP-jére** oldódik fel a név.

## SSH belépés LXC / Ubuntu esetén

**Probléma:**
- LXC-ben csak root van, SSH login tiltva root-al
 
**Ajánlott megoldás:**
- Regular user létrehozása
- SSH belépés engedélyezése jelszóval vagy SSH kulccsal

**Nem ajánlott megoldás:**
- Root SSH login engedélyezése (`PermitRootLogin yes`)
- SSH belépés engedélyezése jelszóval vagy SSH kulccsal

## LXC Samba / NFS megosztás Proxmoxon

**Probléma:**  
- Unprivileged LXC nem tud közvetlenül SMB/CIFS megosztást mountolni  
- Race condition: host próbál mountolni, mielőtt a VM/NAS elérhető lenne  
- QBittorrent nem tud a megosztásra írni, ha nincs mountolva  

**Megoldás:**  
- SMB/NFS mountolása először a Proxmox hoston  
- Host továbbadja a mountot LXC-nek (`mp0:` konfiguráció)  
- Systemd script:
  - Várja, hogy a VM/NAS elérhető legyen (ping / port check)  
  - Csak ha elérhető, mountol  
  - QBittorrent csak a mount után indul, leáll, ha a megosztás eltűnik  

**Biztonsági megjegyzés:**  
- Privileged LXC esetén a **konténer root user és a Proxmox host root user ugyanaz**, így közvetlen mount lehetséges, de **nagyon kockázatos**  
- Hoston mountolva uid/gid és jogosultságok megfelelő beállítása az írás/olvasás miatt
