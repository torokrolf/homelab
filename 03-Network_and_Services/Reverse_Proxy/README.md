← [Back to the Homelab main page](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Hungarian](README_HU.md)

---

# Reverse Proxy

I use a Reverse Proxy because it provides a simple and transparent way to manage **SSL/TLS certificates** for my homelab services.

- A wildcard certificate can be easily assigned to all subdomains
- It hides internal server IP addresses, ports, and paths from the URL, which improves security and simplifies access
- Thanks to its graphical interface, it can be configured quickly and clearly

---

## Using local DNS names (Nginx / Traefik)

A **key design principle** is that **neither Nginx nor Traefik uses fixed IP addresses**, but instead relies on **local DNS names**.

The reason for this is that **when an IP address changes, there is no need to modify every configuration** — it is sufficient to **update the corresponding record on the centralized DNS server**.

This approach is:
- **More flexible** – IP changes do not require reconfiguration
- **More transparent** – descriptive hostnames instead of fixed IP addresses

---

## SSL/TLS (Let’s Encrypt) – DNS-01 Wildcard solution

In the homelab environment, the browser showed warnings because the services were not accessible over HTTPS.  
The solution was to use a **Reverse Proxy with Let’s Encrypt SSL/TLS certificates**, using **DNS-01 challenge–based validation**.

**In short**
- HTTPS requires an SSL/TLS certificate
- The **DNS-01 challenge** verifies domain ownership using a DNS TXT record
- Validation is performed using a **Cloudflare API token**
- The Reverse Proxy temporarily creates a TXT record  
  (`_acme-challenge.trkrolf.com  TXT  <ACME identifier>`)

---

← [Back to the Homelab main page](../README_HU.md)
