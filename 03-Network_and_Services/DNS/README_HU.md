[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)
# Publikus és privát domain névfeloldás

- Saját domain a **Namecheap**-en vásárolva, majd **Cloudflare** nameserverre átköltöztetve. Publikus szolgáltatások nem elérhetők; lokálisan érem el, távolról VPN-en keresztül.
- **Nginx Proxy Manager**-t használok a szolgáltatások kényelmes, portszám nélküli, nevükön keresztüli eléréshez.
- **SSL tanúsítvány** Let's Encrypt-tel (DNS-01 challenge + wildcard), így nem látok a böngészőben figyelmeztetést, hogy HTTP-t használok.
- Privát domain (`otthoni.local`) a **BIND9 DNS** szerver oldja fel.
- **DNS override:** a homelab hálózaton belül a `*.trkrolf.com` kéréseket a lokális DNS IP-címére irányítom, így nem a publikus DNS szerver oldja fel, és internetkapcsolat nélkül is működik.



