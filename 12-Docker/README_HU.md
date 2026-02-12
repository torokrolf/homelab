← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Hungarian](README_HU.md)

---

# Docker
---

## Jelenleg futó Docker szolgáltatások

| Szolgáltatás | Host LXC      | Futtatás | Megjegyzés                               |
|--------------|----------------|----------|-------------------------------------------|
| **Traefik**   | traefik-224   | Docker   | Reverse proxy és SSL kezelés              |
| **Nginx**     | nginx-202     | Docker   | Teszt webszerver / belső alkalmazások    |
| **Portainer** | portainer-219 | Docker   | Docker menedzsment felület               |
| **Gotify**    | gotify-226    | Docker   | Értesítési szerver                       |
| **Jellyseerr**| servarr-225   | Docker   | Média kérések kezelése                   |
| **Radarr**    | servarr-225   | Docker   | Filmgyűjtemény kezelő                    |
| **Prowlarr**  | servarr-225   | Docker   | Indexer menedzser Radarr/Sonarr-hoz     |
| **Sonarr**    | servarr-225   | Docker   | Sorozatgyűjtemény kezelő                 |
| **Bazarr**    | servarr-225   | Docker   | Feliratkezelő Sonarr/Radarr mellé       |

---

## Docker - Miért Docker

- **Kernel-függetlenség**: LXC használata mellett többször belefutottam olyan hibákba, ahol egy-egy szolgáltatás csak meghatározott Linux kernel-verzión futott stabilan. A gazdagép frissítése után a szolgáltatások gyakran megálltak vagy újra kellett konfigurálni őket. A Docker izolációs rétege megszünteti ezt a közvetlen függőséget, így a rendszer stabilabb marad kernel-frissítések után is.

- **Telepítési komplexitás**: Míg LXC-ben minden alkalmazást manuálisan, lépésről lépésre kell telepíteni az OS-en belül, a Docker-nél az előre csomagolt image-ek  leegyszerűsítik a folyamatot. Nincs szükség a függőségek egyenkénti vadászatára.

---
← [Vissza a Homelab főoldalra](../README_HU.md)








