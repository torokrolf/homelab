← [Back to Homelab Home](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Automation

| Service / Tool | Description |
|----------------|------------|
| Automation     | Ansible, Semaphore, Cron, Cronicle |

# Ansible + Semaphore Server

The Ansible server provides central automation and configuration management for the homelab client machines.  
The Semaphore server allows running Ansible playbooks via a simple graphical interface.

**Semaphore is shown in the image below.**

<img src="https://github.com/user-attachments/assets/d2541a25-8dd5-45f3-b828-d7ed8bf819ad" alt="Semaphore" width="900">

---

## ⚙️ Implemented Automation Tasks

- **Update task**: Updating operating systems and applications on Proxmox VM/LXC clients  
- **Time zone configuration**: Correct time zone set on every client  
- **APT Cache NG management**: Local APT Cache NG was configured via Ansible, not individually on each client  
- **User creation and password setup**: Created users with the same name on all target machines for **simple, consistent execution**  
- **SSH key distribution**
---

← [Back to Homelab Home](../README.md)


