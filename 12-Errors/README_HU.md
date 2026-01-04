# Errors

## DNS névfeloldási probléma internet nélkül---megoldás DNS override

**Probléma**:
- A `*.trkrolf.com` (pl. `zabbix.trkrolf.com`) publikus domain, a Cloudflare nameserverre irányult, ami a 192.168.2.202 Nginx IP-t adta vissza.
- Ha a homelabnak **nem volt internetkapcsolata**, a név nem oldódott fel, mert a publikus DNS nem volt elérhető.

**Megoldás**:
- **DNS override / lokális BIND9 DNS**: a `*.trkrolf.com` lekérdezéseket a helyi DNS szerver kezeli.
- Így internet nélkül is mindig a **192.168.2.202 Nginx IP-jére** oldódik fel a név.

## SSH belépési probléma LXC / Ubuntu esetén

**Probléma:**
- LXC-ben a `root` az alapértelmezett felhasználó, nincs regular user
- SSH-n keresztül a root belépés nem működik (Ubuntu Desktopon is)
- Alapértelmezetten a root SSH login tiltva van

**Megoldás:**
- Regular user létrehozása
- SSH belépés engedélyezése:
  - jelszavas autentikációval, vagy
  - SSH kulcsalapú autentikációval
- Root SSH login engedélyezése lehetséges, de **nem javasolt** biztonsági okokból
