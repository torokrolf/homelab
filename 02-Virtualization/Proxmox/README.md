← [Back to the Homelab main page](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Hungarian](README_HU.md)

---

# Proxmox

---

## VMs and LXCs Running on Proxmox
<img src="https://github.com/user-attachments/assets/e218f011-7896-4dbe-b5e2-0e13861d0909" alt="Image description" width="500"/>

---

## VM / LXC Naming Convention

All virtual machines and LXC containers running in the Proxmox environment follow a unified naming convention to ensure easier identification and management.

**LXC format:**  
`<service-name>-<last-ip-octet>`

- **Examples:** `unbound-223`, `traefik-224`

**VM format:**  
`<os-name>-<last-ip-octet>`

- **Examples:** `winsserver-234`, `win11client-231`

---

## VM Template + Cloud-init Usage

**Templates are available for LXC, but Cloud-init is not supported!**

Since most of my VMs on Proxmox are running Ubuntu, I created an **Ubuntu VM template** so I don’t have to install the OS, apply updates, or configure SSH keys every time.

**Creation process:**  
- Configure the base VM (updates, Cloud-init installation)  
- Prepare the VM to be converted into a template:  
  - Remove SSH keys  
  - Clear the hostname  
  - Enable DHCP  
- Convert the VM into a template

**Usage:**  
- New VMs are simply cloned from the template  
- Using Cloud-init, the most important settings are configured:  
  - Hostname  
  - SSH keys  
  - Network configuration  
  - Domain and DNS servers

---

## Proxmox 8 → 9 and PBS 3 → 4 Upgrade

I have been using the system for several months, and when Proxmox 9 and PBS 4 were released, I was curious whether an already configured environment could be upgraded without issues.

- Proxmox **8 → 9** upgrade completed.  
  - On one Proxmox host, the system was upgraded **in-place**.
  - On the other Proxmox host, I performed a **fresh installation** of Proxmox VE 9, then restored the VMs from **PBS backups**.

- Proxmox Backup Server (**PBS**) was also upgraded: **3 → 4**.

---

← [Back to the Homelab main page](../README_HU.md)
