← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# 🌐 Bind9 DNS

- **Bind9** szolgáltatásom két célt szolgál:  
  1. Az **otthoni `.local` domain**-emre autoritatív, így az otthoni gépek és szolgáltatások mindig elérhetők.  
  2. A **`trkrolf.com`** domain felülírása az **NGINX szerverem IP-címére**, így internetkapcsolat hiányában is elérem az otthoni szolgáltatásokat, mivel a névfeloldás nem a Cloudflare nameserverről történik.  

- Részlet a BIND9 db.otthoni.local zónafájljáról
<img src="https://github.com/user-attachments/assets/12686bdf-316a-4b5a-9f78-95d481fe005f" alt="Kép leírása" width="500"/>

---

← [Vissza a Homelab főoldalra](../README_HU.md)










