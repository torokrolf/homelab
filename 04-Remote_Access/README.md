← [Back to Homelab Home](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Remote Access

| Service / Tool | Description |
|----------------|------------|
| **Remote Access** | SSH (Termius), RDP (Guacamole) |

---

## RDP

- **Why Guacamole:**  
  - Convenient access to multiple machines from a browser  
  - Better than Proxmox built-in RDP because it can **forward audio** if needed  
  - From a central location, I can access **any machine via RDP** with one click  
  - **Clipboard transfer issues** that sometimes occurred in Proxmox work reliably in Guacamole

---

## SSH

### SSH – Linux Settings

- **Timeout configuration**: automatically disconnect inactive SSH sessions  
- **Disable root login via SSH**: prevent direct root access  
- **Password login disabled**  
- **Use key-based authentication**: minimize password logins for stronger security  
  - SSH key configured  
  - Without passphrase

---

### SSH – Why Termius

- Manage multiple machines from one place, **with profiles and groups**  
- Built-in **SSH key management**: easy import and use of keys  
- Convenient **cross-platform**: Windows, Linux, macOS, mobile  
- Encrypted configurations, easily **synchronized across devices**

---

← [Back to Homelab Home](../README.md)
