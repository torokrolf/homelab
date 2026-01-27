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

- **Kernel-függetlenség**: LXC használata mellett többször belefutottam olyan hibákba, ahol egy-egy szolgáltatás csak meghatározott Linux kernel-verzión futott stabilan. A gazdagép frissítése után a szolgáltatások gyakran megálltak vagy újra kellett konfigurálni őket. A Docker izolációs rétege megszünteti ezt a közvetlen függőséget, így a rendszer stabilabb marad kernel-frissítések után is.

- **Telepítési komplexitás**: Míg LXC-ben minden alkalmazást manuálisan, lépésről lépésre kell telepíteni az OS-en belül, a Docker-nél az előre csomagolt image-ek  leegyszerűsítik a folyamatot. Nincs szükség a függőségek egyenkénti vadászatára.

---
← [Vissza a Homelab főoldalra](../README_HU.md)







