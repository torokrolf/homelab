## DNS névfeloldási probléma internet nélkül---megoldás DNS override

**Probléma**:
- A `*.trkrolf.com` (pl. `zabbix.trkrolf.com`) publikus domain, a Cloudflare nameserverre irányult, ami a 192.168.2.202 Nginx IP-t adta vissza.
- Ha a homelabnak **nem volt internetkapcsolata**, a név nem oldódott fel, mert a publikus DNS nem volt elérhető.

**Megoldás**:
- **DNS override / lokális BIND9 DNS**: a `*.trkrolf.com` lekérdezéseket a helyi DNS szerver kezeli.
- Így internet nélkül is mindig a **192.168.2.202 Nginx IP-jére** oldódik fel a név.

## SSH-val nem lehet belépni Ubuntu LXC-be

**Probléma:**
- SSH kapcsolat sikertelen az Ubuntu LXC konténerbe
- Az LXC-ben csak a `root` felhasználó létezik
- Alapértelmezett beállítások mellett a belépés nem működik

**Ok:**
- LXC környezetben a `root` felhasználóval történő SSH belépés alapértelmezetten tiltva van
- Ez egy biztonsági alapbeállítás

**Megoldás:**
- Új felhasználó létrehozása az LXC-ben
- SSH belépés engedélyezése:
  - jelszavas autentikációval, vagy
  - SSH kulcsalapú autentikációval

**Nem ajánlott megoldás:**
- Root SSH login engedélyezése (`PermitRootLogin yes`)

**Biztonsági megfontolás:**
- A root SSH belépés növeli a támadási felületet
- Egy kompromittált root fiók az egész konténer biztonságát veszélyezteti
