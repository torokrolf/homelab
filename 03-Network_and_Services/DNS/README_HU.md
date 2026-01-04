[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)
# Publikus és privát domain névfeloldás

## 🌐 Publikus domain

- Saját domain vásárlva a **Namecheap**-en, majd **Cloudflare** nameserverre átköltöztetve.  
- Publikus szolgáltatások: **nem elérhetők közvetlenül**; lokálisan érem el, távolról **VPN-en keresztül**.  
- **SSL tanúsítvány**: Let's Encrypt, DNS-01 challenge + wildcard → böngésző nem jelez HTTP figyelmeztetést.  

## 🖥️ Nginx Proxy Manager

- Használat célja: kényelmes, **portszám nélküli, domain néven történő hozzáférés** a szolgáltatásokhoz.  

## 🔐 Privát domain

- Privát domain: **`otthoni.local`**  
- Feloldás: **BIND9 DNS szerver**  

### DNS override

- A homelab hálózaton belül a `*.trkrolf.com` kéréseket **a lokális DNS IP-címére irányítom**.  
- Előny:  
  - Nem a publikus DNS szerver oldja fel a nevet  
  - Internetkapcsolat nélkül is működik az otthoni szolgáltatások elérése




