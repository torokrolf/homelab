← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Nginx Reverse Proxy

Az NPM-et azért használom, mert egyszerűen lehet vele **reverse proxy-t és SSL-t kezelni** a homelab szolgáltatásaimhoz.  
- Könnyen hozzárendelhetem a wildcard tanúsítványt minden aldomainhez  
- segítségével elrejtem a belső szerverek IP-címét, portját és path-jét. Ez védi a szervert, és egyszerűsíti a hozzáférést.
- Grafikus felülete miatt gyorsan és átláthatóan konfigurálható

---

## SSL/TLS (Let’s Encrypt) – DNS-01 Wildcard megoldás

A homelabban a böngésző figyelmeztetett, mert nem HTTPS-t használtam. A megoldás: hogy **Nginx Proxy Managerrel (NPM)** használok **Let’s Encrypt SSL/TLS tanúsítványt**, **DNS-01 challenge** alapú hitelesítéssel.

**Lényeg röviden**
- A HTTPS működéséhez SSL/TLS tanúsítvány szükséges
- A **DNS-01 challenge** DNS TXT rekorddal igazolja a domain tulajdonjogát
- A hitelesítés **Cloudflare API token** segítségével történik
- Az NPM ideiglenes TXT rekordot hoz létre (_acme-challenge.trkrolf.com  TXT  <ACME azonosító>)

---

← [Vissza a Homelab főoldalra](../README_HU.md)










