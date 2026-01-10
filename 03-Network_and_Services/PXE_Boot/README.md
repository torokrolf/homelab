← [Back to Homelab Home](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# iVentoy PXE Boot Server

Goal: No need to run separate installers on each machine from USB or CD; with iVentoy, I can boot any ISO (Clonezilla, Windows installer, Ubuntu installer, etc.).

---

## 💻 Tests

- **Running Clonezilla**:  
  - For cloning machines over SSH  
  - Testing disaster recovery with Clonezilla

- **Automatic startup**:  
  - iVentoy service created, so it **starts automatically at system boot**, which is better than starting via cron

**In the image below, the bottom row shows a machine connected to the PXE server.**

<img width="800" alt="image" src="https://github.com/user-attachments/assets/b9906010-79dc-44ec-b386-403fbe40a8f9" />

---

← [Back to Homelab Home](../README.md)
