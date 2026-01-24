← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Reverse Proxy

Azért használok Reverse Proxy-t, mert egyszerű és átlátható módon teszi lehetővé az **SSL/TLS tanúsítványok kezelését** a homelab szolgáltatásaimhoz.

- Könnyen hozzárendelhető egy wildcard tanúsítvány minden aldomainhez
- Elrejti a belső szerverek IP-címét, portját és útvonalát az URL-ből, ami növeli a biztonságot és egyszerűsíti a hozzáférést
- Grafikus felületének köszönhetően gyorsan és átláthatóan konfigurálható

---

## Lokális DNS nevek használata (Nginx / Traefik)

**Fontos tervezési elv**, hogy **sem Nginx, sem Traefik esetén nem fix IP-címeket használok**, hanem **lokális DNS neveket**.

Ennek oka, hogy **IP-cím változás esetén ne kelljen minden konfigurációt módosítani** – elegendő legyen **csak a központosított DNS szerveren átírni** az adott rekordot.

Ez a megközelítés:
- **rugalmasabb** – IP-csere esetén nincs újrakonfigurálás
- **átláthatóbb** – beszédes hostnevek fix IP-címek helyett

---

## SSL/TLS (Let’s Encrypt) – DNS-01 Wildcard megoldás

A homelab környezetben a böngésző figyelmeztetett, mert a szolgáltatások nem HTTPS-en keresztül voltak elérhetők.  
A megoldás az volt, hogy **Reverse Proxy-t használok Let’s Encrypt SSL/TLS tanúsítvánnyal**, **DNS-01 challenge** alapú hitelesítéssel.

**Lényeg röviden**
- A HTTPS használatához SSL/TLS tanúsítvány szükséges
- A **DNS-01 challenge** egy DNS TXT rekord segítségével igazolja a domain tulajdonjogát
- A hitelesítés **Cloudflare API token** használatával történik
- A Reverse Proxy ideiglenes TXT rekordot hoz létre  
  (`_acme-challenge.trkrolf.com  TXT  <ACME azonosító>`)

---

← [Vissza a Homelab főoldalra](../README_HU.md)
