← [Back to the Homelab main page](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Hungarian](README_HU.md)

---

# Docker szolgáltatások a Homelabban, LXC konténerben használva

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

## Megjegyzések

- Minden szolgáltatás saját **LXC konténerben** fut, azon belül Docker izolálja az egyes konténereket.
- Ez **könnyen elkülöníti a szolgáltatásokat**, frissíthetőek az image-ek, a hálózat tisztán tartható.

---




