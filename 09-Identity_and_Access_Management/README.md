← [Back to Homelab Home](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Password Management Overview

| Service           | Tool         |
|------------------|-------------|
| Password Manager  | Vaultwarden |


---

<a name="iam"></a>
## 1.7 IAM

### 1.7.1 FreeIPA as LDAP
- Centralized user and permission management across the entire lab.
- Unified configuration of Sudo rules.

### 1.7.2 FreeRADIUS
- **pfSense Authentication**: Access to the pfSense GUI is handled via RADIUS.
- **Management**: SQL + PhpMyAdmin integration for user management.
- **Safety Net**: Local user fallback configured to prevent lockout.

---
---

## Vaultwarden Password Manager

The purpose of Vaultwarden: **self-hosted, independent password management for the homelab**.

---

### 🔐 Features

- **Secure password storage**: All homelab passwords **never leave the local network**.  
- **Self-hosted**: full control over the server.  

---

← [Back to Homelab Home](../README.md)
