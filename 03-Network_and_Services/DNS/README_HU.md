## Publikus és privát domain névfeloldás

- Saját domain a **Namecheap**-en vásárolva, majd **Cloudflare** nameserverre átköltöztetve. Publikus szolgáltatások nem elérhetők; lokálisan érem el, távolról VPN-en keresztül.
- **Nginx Proxy Manager**-rel portszám nélküli névfeloldás a szolgáltatásokhoz. **SSL tanúsítvány** Let's Encrypt-tel (DNS-01 challenge + wildcard).
- Privát domain (`otthoni.local`) a **BIND9 DNS** szerver oldja fel.
- **DNS override:** a homelab hálózaton belül a `*.trkrolf.com` kéréseket a lokális DNS IP-címére irányítom, így nem a publikus DNS szerver oldja fel, és internetkapcsolat nélkül is működik.

Nginx Proxy Manager-ből egy részlet a proxy hosts-ról
<img src="https://github.com/user-attachments/assets/3a8d190b-52aa-4a94-be9f-9aec13829945" alt="Kép leírása" width="700"/>

- Pi-hole
<img src="https://github.com/user-attachments/assets/2d1971e8-aa55-4ebf-9fb2-3b0e95681515" alt="Kép leírása" width="700"/>

- Részlet a BIND9 db.otthoni.local zónafájljáról
<img src="https://github.com/user-attachments/assets/12686bdf-316a-4b5a-9f78-95d481fe005f" alt="Kép leírása" width="500"/>
