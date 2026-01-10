← [Back to Homelab Home](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# 🌐 Bind9 DNS

- My **Bind9** service serves two purposes:  
  1. It is authoritative for my **home `.local` domain**, ensuring that home machines and services are always reachable.  
  2. Overrides the **`trkrolf.com`** domain to point to my **NGINX server IP**, so home services are accessible even without an internet connection, as name resolution does not rely on the Cloudflare nameserver.  

- Excerpt from the BIND9 `db.otthoni.local` zone file:
<img src="https://github.com/user-attachments/assets/12686bdf-316a-4b5a-9f78-95d481fe005f" alt="Image description" width="500"/>

---

← [Back to Homelab Home](../README.md)
