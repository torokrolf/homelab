← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Nginx Reverse Proxy

- Nginx Proxy Manager-ből egy részlet a proxy hosts-ról
- 
![Kép leírása](https://github.com/user-attachments/assets/3a8d190b-52aa-4a94-be9f-9aec13829945)

<img src="https://github.com/user-attachments/assets/3a8d190b-52aa-4a94-be9f-9aec13829945" alt="Kép leírása" width="700"/>

---

## SSL/TLS (Let’s Encrypt) – DNS-01 Wildcard megoldás

A homelabban zavaró volt a böngészőben megjelenő figyelmeztetések, miszerint nem HTTPS-t használok. Erre megoldás, hogy **Nginx Proxy Managerrel (NPM)** használok **Let’s Encrypt SSL/TLS tanúsítványt**,  
**DNS-01 challenge** alapú hitelesítéssel.

### Lényeg röviden
- A HTTPS működéséhez SSL/TLS tanúsítvány szükséges
- A **DNS-01 challenge** DNS TXT rekorddal igazolja a domain tulajdonjogát
- A hitelesítés **Cloudflare API token** segítségével történik
- Az NPM ideiglenes TXT rekordot hoz létre


---

← [Vissza a Homelab főoldalra](../README_HU.md)





