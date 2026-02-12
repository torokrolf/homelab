← [Back to Homelab main page](../README_EN.md)

[🇬🇧 English](README.md) | [🇭🇺 Hungarian](README_HU.md)

---

# Docker
---

## Currently running Docker services

| Service      | Host LXC      | Runtime | Notes                                  |
|--------------|----------------|---------|-----------------------------------------|
| **Traefik**   | traefik-224   | Docker  | Reverse proxy and SSL termination       |
| **Nginx**     | nginx-202     | Docker  | Test web server / internal apps        |
| **Portainer** | portainer-219 | Docker  | Docker management UI                   |
| **Gotify**    | gotify-226    | Docker  | Notification server                    |
| **Jellyseerr**| servarr-225   | Docker  | Media request management               |
| **Radarr**    | servarr-225   | Docker  | Movie collection manager               |
| **Prowlarr**  | servarr-225   | Docker  | Indexer manager for Radarr/Sonarr     |
| **Sonarr**    | servarr-225   | Docker  | TV series collection manager           |
| **Bazarr**    | servarr-225   | Docker  | Subtitle manager for Sonarr/Radarr    |

---

## Docker – Why Docker

- **Kernel independence**: While using LXC, I ran into several issues where some services would only run reliably on specific Linux kernel versions. After host kernel updates, services often stopped or needed to be reconfigured. Docker adds an isolation layer that removes this direct dependency, keeping the system more stable after kernel upgrades.

- **Installation simplicity**: In LXC, applications need to be installed manually, step by step, within the OS. With Docker, prebuilt images simplify the process, eliminating the need to manually track and install individual dependencies.

---
← [Back to Homelab main page](../README_EN.md)

