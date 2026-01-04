# Errors

## Publikus domain névfeloldás internet nélkül---megoldás DNS override

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

## LXC SMB/CIFS megosztás Proxmoxon

**Probléma:**  
- Unprivileged LXC konténer nem tud közvetlenül SMB/CIFS megosztást mountolni  
- Privileged LXC esetén a konténer root-ja és a Proxmox host root-ja ugyanaz → **biztonsági kockázat**  
- Race condition: ha a host mountolná a megosztást, de a megosztást nyújtó VM vagy NAS még nem elérhető, a mount meghiúsul  

**Megoldás:**  
- SMB/CIFS mountolása **először a Proxmox hoston**, majd továbbadása LXC-nek (`mp0:` konfigurációval)  
- Ügyelni a jogosultságokra (uid/gid, file_mode/dir_mode), hogy a konténerben is írható legyen  
- Host mount script + systemd szolgáltatás, ami várja, hogy a megosztás elérhető legyen, majd mountol  

**Biztonsági megjegyzés:**  
- Privileged LXC közvetlen mountja csak tesztelésre, éles környezetben **nem javasolt**  
- Unprivileged LXC + host mount → biztonságos és működőképes megoldás
