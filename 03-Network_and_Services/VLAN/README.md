← [Back to Homelab Home](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# VLAN Setup and Network Segmentation

- **Create a VLAN interface in Proxmox** (`vmbr0.30`), associated with the `vmbr0` bridge with VLAN tag 30.  
- Enable **VLAN-aware mode** on the `vmbr0` bridge so VLAN tags are properly handled.  
- Assign **VLAN tags to the appropriate VMs**, separating them from the untagged 2.0 network.  
- **Create a new subnet for the VLAN** (192.168.3.0/24), with the default gateway set to the pfSense VLAN interface.  
- **Create a VLAN interface on pfSense** and assign an IP address for the VLAN network.  
- Configure **pfSense firewall rules and NAT** for communication between the VLAN and other networks.  
- **Configure TP-Link SG108E switch VLANs** to handle trunked traffic.  
- **Add a static route on the ASUS router** so that the 1.0 network can reach the VLAN network.  
- **Enable DHCP** on the pfSense VLAN interface.
