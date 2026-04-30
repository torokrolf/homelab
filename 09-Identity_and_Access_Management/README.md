← [Back to Homelab Home](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

# 1. Identity and Access Management 

---

## 1.1 📚 Table of Contents

- [1.2 FreeIPA as LDAP](#freeipa)
- [1.3 Authentik (IdP & SSO)](#authentik)
- [1.4 Teleport (Access Plane)](#teleport)
- [1.5 Vaultwarden (Password Manager)](#vaultwarden)

---

<a name="freeipa"></a>

## 1.2 FreeIPA as LDAP
- **Centralized Identity Management:** Unified user and permission management across the entire lab environment.
- **Sudo Policy Enforcement:** Consistent configuration of sudo rules and host-based access control (HBAC).

---

<a name="authentik"></a>

## 1.3 Authentik (Identity Provider & SSO)

Authentik serves as the central **Identity Provider (IdP)** for the homelab, enabling modern security protocols and a seamless, secure authentication experience.

| Application | Method | Strategy / Notes |
| :--- | :--- | :--- |
| **Nextcloud, Grafana** | OIDC | Native OIDC integration for granular permission and role mapping. |
| **Portainer, Jellyfin** | OIDC | Modern authentication implemented via native settings or plugins. |
| **Teleport, ArgoCD** | OIDC | Infrastructure-level access integrated with centralized SSO. |
| **TrueNAS SCALE** | OIDC | Securing the storage layer with a centralized Identity Provider. |
| **Guacamole, Semaphore**| OIDC | Remote access and automation powered by OIDC workflows. |
| **Prometheus / AdGuard** | Proxy Provider | External protection (Forward Auth) for apps lacking native OIDC support. |
| **Vaultwarden** | Proxy Provider | Traefik-level security layer added in front of the password manager. |
| **Switch UI, Webmin** | Proxy Provider | "Locking down" network hardware and admin web interfaces. |
| **Arr Stack, Gotify** | Proxy Provider | Unified external authentication layer for media and notification services. |
| **pfSense** | **LOCAL** | **Critical:** Excluded from SSO to avoid circular dependencies. |
| **FreeIPA** | **LOCAL** | **Core Layer:** The directory service must not depend on the upstream IdP. |
| **Proxmox VE 1 & 2** | OIDC / Local | OIDC for daily use; `root@pam` retained for emergency break-glass access. |
| **PBS (Backup Server)** | OIDC / Local | Secure SSO for backup management with an independent local fallback. |

### 🔐 Key Implementations:
- **Single Sign-On (SSO):** Centralized authentication for all self-hosted services. A single login grants access to all integrated applications for a 24-hour session duration.
- **OAuth2 & OpenID Connect (OIDC):** Native integration with modern applications (e.g., Grafana, Nextcloud) for secure, token-based authentication.
- **Forward Auth / Proxy Provider:** Traefik-based protection for legacy services lacking built-in authentication. It ensures applications are only reachable with a valid Authentik session. Where supported, upstream authentication is bypassed to eliminate "double-login" scenarios.
- **Passwordless & Break-glass Access:** Primary authentication is handled via **Passkey (WebAuthn)** for a passwordless workflow. To prevent lockout, **Static Recovery Tokens** are generated and stored securely offline as a "break-glass" solution in case of hardware authenticator failure.

---

<a name="teleport"></a>

## 1.4 Teleport (Access Plane & Zero Trust)

Teleport provides secure, infrastructure-level access to homelab resources, strictly following **Zero Trust** principles.

### 🛡️ Solutions:
- **Certificate-Based SSH Access:** Replaced static SSH keys with short-lived X.509 certificates. This eliminates the overhead and security risks associated with manual SSH key management (`authorized_keys`).
- **Session Recording & Audit:** All SSH and GUI sessions are fully recorded and searchable. Recorded sessions can be replayed for security audits and incident response.
- **Unified Access Plane:** Provides a consolidated entry point (via Web UI or the `tsh` CLI) to access all servers over SSH without the need for a VPN.
- **RBAC (Role-Based Access Control):** Granular permission management ensuring users can only access resources tagged with specific labels assigned to their roles.

---

<a name="vaultwarden"></a>

## 1.5 Vaultwarden Password Manager

The goal of Vaultwarden is to provide **self-hosted, sovereign password management** within the homelab environment.

### 🔑 Features:
- **Secure Vaulting:** All lab-related credentials are stored locally, ensuring sensitive data **never leaves the internal network**.
- **Full Sovereignty:** Complete control over the server, database, and encryption keys without relying on third-party cloud providers.

---

← [Back to Homelab Home](../README.md)
