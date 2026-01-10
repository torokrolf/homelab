← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Publikus és privát domain névfeloldás

## Publikus domain (Namecheap, Cloudflare)

- Saját domain vásárlva a **Namecheap**-en, majd **Cloudflare** nameserverre átköltöztetve.  
- Publikus szolgáltatások: **nem elérhetők közvetlenül**; lokálisan érem el, távolról **VPN-en keresztül**.  

---

## Privát domain (Bind9)

- Privát domain: **`otthoni.local`**  
- Feloldás: **BIND9 DNS szerver**  

### Privát domain - DNS override

- A homelab hálózaton belül a `*.trkrolf.com` kéréseket **a lokális DNS IP-címére irányítom**.  
- Előny:  
  - Nem a publikus DNS szerver oldja fel a nevet  
  - Internetkapcsolat nélkül is működik az otthoni szolgáltatások elérése

---

← [Vissza a Homelab főoldalra](../README_HU.md)









