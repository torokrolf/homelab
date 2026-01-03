## Publikus és privát domain névfeloldás

- Saját domain a **Namecheap**-en vásárolva, majd **Cloudflare** nameserverre átköltöztetve. Publikus szolgáltatások nem elérhetők; lokálisan érem el, távolról VPN-en keresztül.
- **Nginx Proxy Manager**-rel portszám nélküli névfeloldás a szolgáltatásokhoz. **SSL tanúsítvány** Let's Encrypt-tel (DNS-01 challenge + wildcard).
- Privát domain (`otthoni.local`) a **BIND9 DNS** szerver oldja fel.
- **DNS override:** a homelab hálózaton belül a `*.trkrolf.com` kéréseket a lokális DNS IP-címére irányítom, így nem a publikus DNS szerver oldja fel, és internetkapcsolat nélkül is működik.

- Részlet a BIND9 db.otthoni.local zónafájljáról
<img src="https://github.com/user-attachments/assets/12686bdf-316a-4b5a-9f78-95d481fe005f" alt="Kép leírása" width="500"/>


