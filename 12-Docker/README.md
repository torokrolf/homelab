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
| **Radarr**        | LXC → Docker | Movie library management |
| **Prowlarr**      | LXC → Docker | Indexer manager for Radarr/Sonarr |

---

## Docker – Why Docker

- **Kernel independence**: While using LXC, I ran into several issues where certain services only worked reliably on specific Linux kernel versions. After host kernel updates, services would often stop working or require reconfiguration. Docker adds an additional isolation layer that removes this direct dependency, resulting in a more stable system after kernel upgrades.

- **Installation complexity**: In LXC, applications usually need to be installed manually step by step within the OS. With Docker, prebuilt images significantly simplify this process, eliminating the need to manually track and install individual dependencies.

---
