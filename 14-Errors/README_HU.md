← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Errors

## 📚 Tartalomjegyzék

- [DNS – Publikus domain névfeloldás internet nélkül](#dns---publikus-domain-névfeloldás-internet-nélkül)
- [DNS – Pi-hole blokkolja a Google képtalálatokat mobilon](#dns---pi-hole-blokkolja-a-google-képtalálatokat-mobilon)
- [SSH – SSH belépés LXC / Ubuntu esetén](#ssh---ssh-belépés-lxc--ubuntu-esetén)
- [Megosztás – SMB elérés LXC-ből](##megosztas--smbnfs-eleres-lxc-bol)
- [Race condition – SMB mount sorrendiség](#race-condition--smb-mount-sorrendiség)
- [Megosztás – Dinamikus NFS mount qBittorrenthez + race condition kezelés](#megosztás---dinamikus-nfs-mount-qbittorrentet-futtató-vm-hez-race-condition-kezeléssel-és-qbittorrent-leállítása-ha-a-megosztás-eltűnik)
- [Hardver – Külső SSD stabilitása USB-n](#hardver---külső-ssd-stabilitása-usb-n--tp-link-ue330-on-keresztül-vs-direkt-usb-n-csatlakozás)
- [Hardver – M70q hálózati adapter instabilitás](#hardver---m70q-belső-hálózati-adapter-stabilitási-problémája---megoldás-külső-usb-adapterrel-tp-link-ue330)
- [Hardver – Lokális és publikus DNS problémák Wi-Fi adapter miatt](#hardver---lokális-és-publikus-dns-problémák-laptopom-wi-fi-adaptere-miatt)
- [DDNS – DDNS nem frissül Cloudflare-en pfSense mögött](#ddns---ddns-nem-frissül-cloudflare-en-pfsense-wan-interfészen-lévő-privát-ip-használata-miatt)

---

## DNS - Publikus domain névfeloldás internet nélkül

**Probléma**:
- A `*.trkrolf.com` (pl. `zabbix.trkrolf.com`) publikus domain, a Cloudflare nameserverre irányult, ami a 192.168.2.202 Nginx IP-t adta vissza.
- Ha a homelabnak **nem volt internetkapcsolata**, a név nem oldódott fel, mert a publikus DNS nem volt elérhető.

**Megoldás**:
- **DNS override / lokális BIND9 DNS**: a `*.trkrolf.com` lekérdezéseket a helyi DNS szerver kezeli.
- Így internet nélkül is mindig a **192.168.2.202 Nginx IP-jére** oldódik fel a név.

---

## DNS - Pi-hole blokkolja a Google képtalálatokat mobilon

**Probléma**
- Mobiltelefonon Google keresésnél a **képtalálatokra kattintva** gyakran:
  - nem nyílik meg az oldal
  - vagy a kép nem vezet tovább a forrás weboldalra
- Asztali gépen ez a jelenség nem vagy ritkábban jelentkezik

**Ok**
- Mobilon a Google képtalálatok **nem közvetlen képfájlokra mutatnak**, hanem:
  - hirdetési
  - tracking
  - átirányító (redirect) domaineken keresztül nyílnak meg
- Ezek a domainek gyakran **Pi-hole tiltólistákon szerepelnek**, például:
  - `googleadservices.com`
  - `googletagservices.com`
  - `doubleclick.net`
- Kattintáskor a Google egy köztes tracking linken irányít tovább, amit a Pi-hole DNS szinten blokkol
- Egyes képkiszolgáló / CDN domainek (pl. gstatic.com aldomainjei) szintén tiltólistára kerülhetnek

**Megjegyzés**
- Ez a viselkedés **nem Pi-hole hiba**, hanem a reklám- és követésblokkolás természetes következménye
- A fenti domainek **szándékosan vannak tiltva** sok alapértelmezett és közösségi blocklisten

**Megoldás, amit alkalmazok**
- Ideiglenesen kikapcsolni a Pi-hole-t (pl. mobilról SSH-n keresztül, scripttel)

**Egyéb megoldás, de ez nem ajánlott szerintem**
- Vagy célzott whitelisting alkalmazása (nem ajánlott mindenkinél, mert hirdetések visszatérhetnek)

❗Script megvalósítás: [scripts/smb-vm-mount.sh](/11-Scripts/Android/toggle_pihole_ssh.sh) 

---

## SSH - SSH belépés LXC / Ubuntu esetén

**Probléma:**
- LXC-ben csak root van, SSH login tiltva root-al
 
**Ajánlott megoldás:**
- Regular user létrehozása
- SSH belépés engedélyezése jelszóval vagy SSH kulccsal

**Nem ajánlott megoldás:**
- Root SSH login engedélyezése (`PermitRootLogin yes`)
- SSH belépés engedélyezése jelszóval vagy SSH kulccsal

---

## Megosztás – SMB/NFS elérés LXC-ből

**Probléma:** 
- Unprivileged LXC konténer nem képes közvetlenül megosztást mountolni

**Megoldás:**  
- Megosztás mountolása a Proxmox hoston. Próbáltam systemd-vel, fstab-al, de mindegyiknél fagyott a df a hoston, hiszen nem találta a megosztást. Nálam az autofs ezt megoldotta, így ezzel csatolom Proxmox hosthoz a megosztásokat, ekkor is fagyhat, de 1 perc után rájön, hogy nem találja a megosztást, és utána normálisan működik a df.
- A mountolt könyvtár továbbadása az LXC konténernek bind mounttal (`mp0:`)
- Ügyelni a jogosultságokra (uid/gid, file_mode/dir_mode), hogy a konténerben is írható legyen  

**Biztonság**
- Privileged LXC esetén tudok mountolni SMB megosztást, de ekkor a konténer root-ja és a Proxmox host root-ja ugyanaz → **biztonsági kockázat**  
- Unprivileged LXC + host mount → biztonságos és működőképes megoldás, hiszen a Proxmox root-ja és a konténer root-ja két külön root, és az konténer root-ja alacsonyabb jogokkal rendelkezik, így a Proxmox hoston nem csinálhat veszélyesműveleteket.

---

## Hardver - Külső SSD stabilitása USB-n — TP-Link UE330-on keresztül vs. direkt USB-n csatlakozás

**Probléma:** 
- Egy **Samsung 870 EVO** külső SSD néha **lekapcsolódott**, amikor közvetlenül USB-re volt kötve.  

**Megoldás:**  
- Az SSD **TP-Link USB hub-on keresztül** csatlakoztatva **stabilan működik** már több mint 6 hónapja.  
- Ennek oka valószínűleg a TP-Link UE330 stabilabb áramellátása.

---

## Hardver - M70q belső hálózati adapter stabilitási problémája---megoldás külső USB adapterrel (TP-Link UE330)

**Probléma**:
- M70q gépen a belső hálózati adapter néha elveszíti a kapcsolatot, ami kellemetlen, hiszen többet nem érem el hálózaton (Pl.:SSH), és le kell ülnöm a gép elé, hogy újraindítsam a hálózati adaptert, ami után ismét működik.

**Egy lehetséges megoldás**:
- Írhatok egy scriptet, ami egy másik eszközt, például routert pingel, és ha nem sikerül, akkor újraindítja a hálózati adaptert.

**Általam választott megoldás**:
- TP-Link UE330 USB hálózati adapter használata: stabilan működik, a kapcsolat fél éve problémamentes.

---

## Hardver - Lokális és publikus DNS problémák laptopom Wi-Fi adaptere miatt

### Probléma
- A lokális DNS néha nem oldotta fel a helyi gépek neveit, sőt néha a publikus neveket (pl. google.com) sem.  
- A hálózati adapter a MediaTek 7921 volt, ami instabil DNS kezeléshez vezetett Linux alatt.

### Megoldás
- A MediaTek 7921 helyett Intel AX210 adaptert használtam.  
- Az Intel adapterrel a DNS feloldás stabilan működik, lokális és publikus neveknél is.

---

## DDNS - DDNS nem frissül Cloudflare-en PFSense WAN interfészen lévő privát IP használata miatt

### Probléma
- Ha a hálózatom publikus IP-je változik, a Cloudflare rekord, ami a publikus IP-t tartalmazza, nem frissül automatikusan.  
- A PFSense DDNS státusza piros lett, nem a zöld pipás.  
- Ennek oka, hogy a PFSense WAN interfésze a topológiámban privát IP-t használ, így a változás nem triggereli a DDNS frissítést.
- Eredmény, néha nem értem el az otthoni hálózatomat távolról.

### Megoldás
- Saját script írása, ami ellenőrzi a publikus IP változását, és ha van változás, frissíti a Cloudflare rekordot.  
- Így nem csak a WAN IP (ami nálam privát) változása, hanem a script által észlelt publikus IP-változás is triggerelheti a frissítést.

❗ Script megvalósítás: [scripts/smb-vm-mount.sh](11-Scripts/pfsense/ddns-force-update.sh) 

---

← [Vissza a Homelab főoldalra](../README_HU.md)
