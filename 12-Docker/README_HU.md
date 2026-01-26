← [Back to the Homelab main page](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Hungarian](README_HU.md)

---

# Docker szolgáltatások a Homelabban

Ebben a mappában találhatóak a homelabban futó Docker szolgáltatások.  
Minden szolgáltatás **LXC konténeren belül fut Dockerrel**, néhány szolgáltatás külön LXC-ben a tiszta izoláció és egyszerűbb menedzsment miatt.

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
- Névkonvenció: **container name = szolgáltatás neve**, így könnyen áttekinthető a `docker ps`-ben.

---

## Használat

1. Lépj a szolgáltatás mappájába:

```bash
cd Docker/<szolgáltatás-neve>


---

← [Back to the Homelab main page](../README_HU.md)

