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

## Dinamikus NFS mount qBittorrentet futtató VM-hez race condition kezeléssel és qBittorrent leállítása ha a megosztás eltűnik

**Fontos: Eredetileg SMB megosztást használtam. A TrueNAS megléte esetén a qBittorrent elindult, de ha ezután leállítottam a TrueNAS-t, a qBittorrent nem állt le, mert az SMB nem kezeli jól a váratlan leválasztást, és a df parancs is fagyott. Linuxos környezetben ezért érdemes inkább a natív NFS-t használni. NFS-re váltás után a probléma teljesen megszűnt.**  

**Probléma:** 
- Amikor a kliens gép (Ubuntu/Proxmox) elindul, a systemd megpróbálja elindítani a szolgáltatásokat.  
- Ha a qBittorrent hamarabb indul el, mint ahogy a TrueNAS SMB megosztása felcsatolódna, a torrent kliens hibát dob, vagy rosszabb esetben a helyi meghajtóra kezd el tölteni a hálózati megosztás helyett.  
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
- Systemd szolgáltatás biztosítja a script automatikus indítását és újraindítását
- 
## Külső SSD stabilitása USB-n — TP-Link UE330-on keresztül vs. direkt USB-n csatlakozás

**Probléma:** 
- Egy **Samsung 870 EVO** külső SSD néha **lekapcsolódott**, amikor közvetlenül USB-re volt kötve.  

**Megoldás:**  
- Az SSD **TP-Link USB hub-on keresztül** csatlakoztatva **stabilan működik** már több mint 6 hónapja.  
- Ennek oka valószínűleg a TP-Link UE330 stabilabb áramellátása.

## M70q belső hálózati adapter stabilitási problémája---megoldás külső USB adapterrel (TP-Link UE330)

**Probléma**:
- M70q gépen a belső hálózati adapter néha elveszíti a kapcsolatot, ami kellemetlen, hiszen többet nem érem el hálózaton (Pl.:SSH), és le kell ülnöm a gép elé, hogy újraindítsam a hálózati adaptert, ami után ismét működik.

**Egy lehetséges megoldás**:
- Írhatok egy scriptet, ami egy másik eszközt, például routert pingel, és ha nem sikerül, akkor újraindítja a hálózati adaptert.

**Általam választott megoldás**:
- TP-Link UE330 USB hálózati adapter használata: stabilan működik, a kapcsolat fél éve problémamentes.

## Lokális és publikus DNS problémák laptopom Wi-Fi adaptere miatt

### Probléma
- A lokális DNS néha nem oldotta fel a helyi gépek neveit, sőt néha a publikus neveket (pl. google.com) sem.  
- A hálózati adapter a MediaTek 7921 volt, ami instabil DNS kezeléshez vezetett Linux alatt.

### Megoldás
- A MediaTek 7921 helyett Intel AX210 adaptert használtam.  
- Az Intel adapterrel a DNS feloldás stabilan működik, lokális és publikus neveknél is.

## DDNS nem frissül Cloudflare-en PFSense WAN interfészen lévő privát IP használata miatt

### Probléma
- Ha a hálózatom publikus IP-je változik, a Cloudflare rekord, ami a publikus IP-t tartalmazza, nem frissül automatikusan.  
- A PFSense DDNS státusza piros lett, nem a zöld pipás.  
- Ennek oka, hogy a PFSense WAN interfésze a topológiámban privát IP-t használ, így a változás nem triggereli a DDNS frissítést.
- Eredmény, néha nem értem el az otthoni hálózatomat távolról.

### Megoldás
- Saját script írása, ami ellenőrzi a publikus IP változását, és ha van változás, frissíti a Cloudflare rekordot.  
- Így nem csak a WAN IP (ami nálam privát) változása, hanem a script által észlelt publikus IP-változás is triggerelheti a frissítést.
