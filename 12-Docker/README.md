← [Back to Homelab main page](../README_EN.md)

[🇬🇧 English](README.md) | [🇭🇺 Hungarian](README_HU.md)

---

# Docker
---

## Currently running Docker services

| Service          | LXC + Docker | Notes |
|------------------|--------------|-------|
| **Traefik**       | LXC → Docker | Reverse proxy and SSL management |
| **Nginx**         | LXC → Docker | Test web server / internal applications |
| **Portainer**     | LXC → Docker | Docker management UI |
| **Gotify**        | LXC → Docker | Notification server |
| **Jellyseerr**    | LXC → Docker | Media request management |
| **Radarr**        | LXC → Docker | Movie library manager |
| **Prowlarr**      | LXC → Docker | Indexer manager for Radarr/Sonarr |

---

## Docker – Why Docker

- **Kernel independence**: While using LXC, I ran into several issues where some services would only run reliably on specific Linux kernel versions. After host kernel updates, services often stopped or needed to be reconfigured. Docker adds an isolation layer that removes this direct dependency, keeping the system more stable after kernel upgrades.

- **Installation simplicity**: In LXC, applications need to be installed manually, step by step, within the OS. With Docker, prebuilt images simplify the process, eliminating the need to manually track and install individual dependencies.

---
← [Back to Homelab main page](../README_EN.md)
