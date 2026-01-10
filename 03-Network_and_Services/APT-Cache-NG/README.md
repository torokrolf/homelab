← [Back to Homelab Home](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# APT Cache Proxy
- Used for **VM and LXC updates** orchestrated by Ansible, scheduled at 3:00 AM.  
- Goal: avoid downloading packages separately on every VM/LXC, reducing unnecessary bandwidth usage.  
- The cache proxy stores downloaded packages, so machines fetch updates from the APT cache proxy server instead of the internet.
