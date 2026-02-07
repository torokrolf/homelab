← [Back to the Homelab main page](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Hungarian](README_HU.md)

---

# 1. 📚 Automation

---

## 1.1 Table of Contents

- [Ansible_Semaphore](./Ansible_Semaphore/README.md)
- [Cron_Cronicle](./Cron_Cronicle/README.md)

---

## 1.2 Services

| Service / Tool        | Function / Description |
|-----------------------|----------------------|
| **Ansible**           | Central configuration management and automation for VMs and LXC containers |
| **Semaphore**         | Web interface to run Ansible playbooks; simple and easy-to-manage |
| **Cron**              | Scheduled tasks on Linux systems |
| **Cronicle**          | Web front-end for Cron |

---

## 1.3 Ansible + Semaphore Server

The Ansible server provides central automation and configuration management for the homelab client machines.  
The Semaphore server allows running Ansible playbooks via a simple graphical web interface.

**The screenshot below shows Semaphore in action.**

<img src="https://github.com/user-attachments/assets/d2541a25-8dd5-45f3-b828-d7ed8bf819ad" alt="Semaphore Web UI screenshot" width="900">

---

### 1.3.1 Implemented Automation Tasks

- **Update tasks**: Automates OS and application updates on Proxmox VM/LXC clients.  
- **Time zone configuration**: Ensures the correct time zone is set on all client machines.  
- **APT Cacher NG management**: Configures local APT Cacher NG via Ansible instead of manually on each client.  
- **User creation and password setup**: Creates users with the same name on all target machines for **simple and consistent management**.  
- **SSH key distribution**

---

← [Back to the Homelab main page](../README_HU.md)


