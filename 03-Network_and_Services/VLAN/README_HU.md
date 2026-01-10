← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# VLAN kialakítása és hálózati szegmentáció

- **Proxmox alatt VLAN interface létrehozása** (`vmbr0.30`), amely a `vmbr0` bridge-hez tartozik VLAN tag 30-cal.
- A `vmbr0` bridge-en **VLAN-aware** mód engedélyezése, hogy a VLAN tagek kezelése ne dobódjon el.
- A megfelelő **VM-ek VLAN taggel ellátása**, így elkülönültek a tag nélküli 2.0 hálózattól.
- **Új alhálózat létrehozása a VLAN számára** (192.168.3.0/24), default gateway a pfSense VLAN interfésze.
- **pfSense-en VLAN interfész létrehozása** és IP-cím kiosztása a VLAN hálózathoz.
- **pfSense firewall szabályok és NAT konfiguráció** a VLAN és más hálózatok közötti kommunikációhoz.
- **TP-Link SG108E switch VLAN konfigurálása** a trunkolt forgalom kezelésére.
- **Statikus route hozzáadása az ASUS routeren**, hogy az 1.0 hálózat elérje a VLAN hálózatot.
- **DHCP szolgáltatás engedélyezése** a pfSense VLAN interfészén.

