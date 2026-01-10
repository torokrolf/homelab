← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Nginx Reverse Proxy

- Nginx Proxy Manager-ből egy részlet a proxy hosts-ról
<img src="https://github.com/user-attachments/assets/3a8d190b-52aa-4a94-be9f-9aec13829945" alt="Kép leírása" width="700"/>

---

## SSL/TLS (Let’s Encrypt) – DNS-01 Wildcard megoldás

A homelabban **Nginx Proxy Managerrel (NPM)** használok **Let’s Encrypt SSL/TLS tanúsítványt**,  
**ACME DNS-01 challenge** alapú hitelesítéssel.

### Lényeg röviden
- A HTTPS működéséhez SSL/TLS tanúsítvány szükséges
- A **DNS-01 challenge** DNS TXT rekorddal igazolja a domain tulajdonjogát
- A hitelesítés **Cloudflare API token** segítségével történik
- Az NPM ideiglenes TXT rekordot hoz létre:
  ```txt
  _acme-challenge.trkrolf.com  TXT  <ACME azonosító>

---

← [Vissza a Homelab főoldalra](../README_HU.md)

