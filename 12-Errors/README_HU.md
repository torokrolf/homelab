## DNS névfeloldási probléma – internet nélkül

Probléma:
- A `*.trkrolf.com` (pl. `torrent.trkrolf.com`) publikus domain, a Cloudflare nameserverre irányult.
- Ha a homelabnak **nem volt internetkapcsolata**, a név nem oldódott fel, mert a publikus DNS nem volt elérhető.

Megoldás:
- **DNS override / lokális BIND9 DNS**: a `*.trkrolf.com` lekérdezéseket a helyi DNS szerver kezeli.
- Így internet nélkül is mindig a **192.168.2.202 Nginx IP-jére** oldódik fel a név.
