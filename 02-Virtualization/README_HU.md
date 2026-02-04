← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Virtualizáció

---

## Type 1 Hypervisor
- **Proxmox VE 9**
  - LXC (Linux konténerek)
  - VM (Virtuális gépek)
  - Template + Cloud-Init

[ TrueNAS / Távoli Storage ]
       |
       +----(NFS/SMB)---->[ Proxmox Host ]
       |                    |
       |                    +--[ AutoFS /mnt/pve/... ]
       |                          |
       |                          +--[ Bind Mount (mp0) ]--> [ LXC Container 1 ]
       |                          +--[ Bind Mount (mp1) ]--> [ LXC Container 2 ]
       |
       +----(NFS/SMB)--------------------------------------> [ Virtual Machine (FSTAB) ]
       |
[ Fizikai Lemez (SSD) ]
       |
       +----(Disk Passthrough /dev/disk/by-id/...)----------> [ VM (TrueNAS / PBS) ]

