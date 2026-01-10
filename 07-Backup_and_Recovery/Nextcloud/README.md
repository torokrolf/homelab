← [Back to Homelab Home](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

# Nextcloud

---

<img width="2542" height="656" alt="image" src="https://github.com/user-attachments/assets/ed38c604-a50b-4b80-a4b4-331a7696582a" />

---

## Advantages of Nextcloud

- Self-hosted file and photo management  
- No need for Google Drive or other cloud services; Nextcloud acts as my own Google Drive  
- Full control and security  

---

## Issues
### Issues – Trusted Domains / Whitelist

Nextcloud only allows access from addresses listed in the `trusted_domains` array in the `config.php` file.

- If accessed via **NGINX reverse proxy** (e.g., `nextcloud.trkrolf.com`), the **DNS name must be added** to the whitelist.  
- If accessed via **local DNS name** (e.g., `nextcloud.otthoni.local`) or **IP address**, these must also be added separately.  
- When using **Tailscale**, the server’s **Tailscale IP** must also be added, otherwise remote access will fail.

📌 If an address is not whitelisted:  
- It may work via IP but not via DNS (or vice versa)  
- Nextcloud will show an “untrusted domain” error

---

← [Back to Homelab Home](../README.md)
