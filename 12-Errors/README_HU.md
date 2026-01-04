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

## SMB megosztás elérése LXC-ből + race condition

**Probléma:**  
- Unprivileged LXC konténer nem tud közvetlenül SMB/CIFS megosztást mountolni  
- Race condition: ha a Proxmox host mountolná a megosztást, de a megosztást nyújtó VM vagy NAS még nem elérhető, a mount meghiúsul  

**Megoldás:**  
- SMB/CIFS mountolása először a Proxmox hoston, majd továbbadása LXC-nek (`mp0:` konfigurációval)  
- Ügyelni a jogosultságokra (uid/gid, file_mode/dir_mode), hogy a konténerben is írható legyen  
- Host mount script + systemd szolgáltatás, ami várja, hogy a megosztás elérhető legyen, majd mountol  

**Biztonsági megjegyzés:**  
- Privileged LXC esetén tudok mountolni SMB megosztást, de ekkor a konténer root-ja és a Proxmox host root-ja ugyanaz → **biztonsági kockázat**  
- Unprivileged LXC + host mount → biztonságos és működőképes megoldás, hiszen a Proxmox root-ja és a konténer root-ja két külön root, és az konténer root-ja alacsonyabb jogokkal rendelkezik, így a Proxmox hoston nem csinálhat veszélyesműveleteket.

## Dinamikus NFS mount qbittorrentet futtató VM-hez race condition kezeléssel

**Probléma:** 
- Amikor a kliens gép (Ubuntu/Proxmox) elindul, a systemd megpróbálja elindítani a szolgáltatásokat.  
- Ha a qBittorrent hamarabb indul el, mint ahogy a TrueNAS NFS megosztása felcsatolódna, a torrent kliens hibát dob, vagy rosszabb esetben a helyi meghajtóra kezd el tölteni a hálózati megosztás helyett.  
- Hasonló hiba lép fel, ha a TrueNAS váratlanul leáll vagy újraindul.

**Megoldás:**  
- Egy háttérben futó (daemon) szkript folyamatosan (30 másodpercenként) ellenőrzi a tároló elérhetőségét:
- Ha a NAS elérhető: Automatikusan felcsatolja a meghajtót, és csak a sikeres csatolás után indítja el a qBittorrentet.  
- Ha a NAS leáll: Azonnal leállítja a qBittorrentet (hogy elkerülje a hibát vagy hogy a helyi meghajtóra kezdjen el letölteni) és tisztán lecsatolja (umount) a könyvtárat.

**Implementáció:**
- Végtelen ciklusos script ellenőrzi, hogy a NAS elérhető-e
- Ha elérhető:
  - Mountolja az NFS megosztást 
  - Elindítja a qBittorrent szolgáltatást, ha még nem fut
- Ha a NAS nem elérhető:
  - Leállítja a qBittorrentet
  - Unmountolja a megosztást
- Systemd szolgáltatás (`nfs_qbittorrent.service`) biztosítja a script automatikus indítását és újraindítását
