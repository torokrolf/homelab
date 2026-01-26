← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Hungarian](README_HU.md)

---

# Docker
---

## Jelenleg futó Docker szolgáltatások

| Szolgáltatás      | LXC + Docker | Megjegyzés |
|------------------|--------------|------------|
| **Traefik**       | LXC → Docker | Reverse proxy és SSL kezelés |
| **Nginx**         | LXC → Docker | Teszt web szerver / belső alkalmazások |
| **Portainer**     | LXC → Docker | Docker menedzsment UI |
| **Gotify**        | LXC → Docker | Értesítési szerver |
| **Jellyseerr**    | LXC → Docker | Média kérések kezelése |
| **Radarr**        | LXC → Docker | Filmgyűjtemény kezelő |
| **Prowlarr**      | LXC → Docker | Indexer menedzser Radarr/Sonarr-hoz |

---

## Docker - Miért Docker

A Docker használata a homelabban több szempontból is nagyon praktikus:

- **Egyszerűség** – gyorsan indíthatóak és frissíthetőek a szolgáltatások, nincs szükség teljes OS telepítésre minden egyes új apphoz.  
- **Izoláció** – minden szolgáltatás saját konténerben fut, így a hibák vagy konfigurációs problémák nem hatnak a többi szolgáltatásra.  
- **Könnyű karbantartás** – image-ek frissítése, backup készítése és konténerek újraindítása egyszerűen, pár parancs segítségével.  
- **Rugalmasság** – új szolgáltatások hozzáadása egyszerű: csak létre kell hozni egy új Docker Compose mappát.  
- **Átláthatóság** – a konténerek nevei és konfigurációi következetesen kezelhetők, könnyen áttekinthető a  Portainer felületén.

---
← [Vissza a Homelab főoldalra](../README_HU.md)





