← [Back to Homelab Home](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Public and Private Domain Resolution

## Public Domain (Namecheap, Cloudflare)

- Purchased my own domain on **Namecheap** and then moved it to **Cloudflare** nameservers.  
- Public services: **not accessible directly**; accessed locally, remotely **through VPN**.  

---

## Private Domain (Bind9)

- Private domain: **`otthoni.local`**  
- Resolution: **BIND9 DNS server**  

### Private Domain - DNS Override

- Within the homelab network, requests for `*.trkrolf.com` are **directed to the local DNS IP**.  
- Advantages:  
  - The name is not resolved by the public DNS server  
  - Home services can be accessed even without an internet connection

---

← [Back to Homelab Home](../README.md)
