## Publikus és privát domain névfeloldás

- Saját domain a **Namecheap**-en vásárolva, majd **Cloudflare** nameserverre átköltöztetve. Publikus szolgáltatások nem elérhetők; lokálisan érem el, távolról VPN-en keresztül.
- **Nginx Proxy Manager**-rel portszám nélküli névfeloldás a szolgáltatásokhoz. **SSL tanúsítvány** Let's Encrypt-tel (DNS-01 challenge + wildcard).
- Privát domain (`otthoni.local`) a **BIND9 DNS** szerver oldja fel.
- **DNS override:** a homelab hálózaton belül a `*.trkrolf.com` kéréseket a lokális DNS IP-címére irányítom, így nem a publikus DNS oldja fel.
