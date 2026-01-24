← [Back to Homelab Home](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Nginx Reverse Proxy

I use NPM because it makes it easy to **manage reverse proxies and SSL** for my homelab services.  
- I can easily assign a wildcard certificate to all subdomains  
- It allows me to hide the internal servers’ IP addresses, ports, and paths. This protects the servers and simplifies access.  
- Its graphical interface makes configuration fast and clear

---

## SSL/TLS (Let’s Encrypt) – DNS-01 Wildcard Method

In my homelab, the browser warned me because I was not using HTTPS. The solution: I use **Let’s Encrypt SSL/TLS certificates with Nginx Proxy Manager (NPM)**, authenticated via the **DNS-01 challenge** method.

**Key points:**  
- SSL/TLS certificate is required for HTTPS  
- **DNS-01 challenge** verifies domain ownership using a DNS TXT record  
- Verification is done via **Cloudflare API token**  
- NPM creates a temporary TXT record (_acme-challenge.trkrolf.com  TXT  <ACME identifier>)

---

← [Back to Homelab Home](../README.md)
