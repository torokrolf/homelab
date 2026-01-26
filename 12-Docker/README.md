← [Back to the Homelab main page](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Hungarian](README_HU.md)

---

# Docker
---

## Currently Running Docker Services

| Service        | LXC + Docker | Notes |
|----------------|--------------|-------|
| **Traefik**    | LXC → Docker | Reverse proxy and SSL management |
| **Nginx**      | LXC → Docker | Test web server / internal applications |
| **Portainer**  | LXC → Docker | Docker management UI |
| **Gotify**     | LXC → Docker | Notifications server |
| **Jellyseerr** | LXC → Docker | Media request management |
| **Radarr**     | LXC → Docker | Movie collection manager |
| **Prowlarr**   | LXC → Docker | Indexer manager for Radarr/Sonarr |

---

## Docker – Why Docker

Using Docker in the homelab is very practical for several reasons:

- **Simplicity** – Services can be started and updated quickly without needing to install a full OS for every new app.  
- **Isolation** – Each service runs in its own container, so errors or configuration issues do not affect other services.  
- **Easy Maintenance** – Updating images, making backups, and restarting containers is simple with a few commands.  
- **Flexibility** – Adding new services is easy: just create a new folder with a Docker Compose setup.  
- **Clarity** – Container names and configurations are consistently managed and easily viewable through Portainer.

---

← [Back to the Homelab main page](../README_HU.md)
