← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# 1. Identity and Access Management 

---

## 1.1 📚 Tartalomjegyzék

- [1.2 FreeIPA](#freeipa)
- [1.3 Authentik](#authentik)
- [1.4 Teleport](#teleport)
- [1.5 Vaultwarden](#vaultwarden)
---

<a name="freeipa"></a>

## 1.2 FreeIPA mint LDAP
- Központosított felhasználó- és jogosultságkezelés a teljes laborban.
- Sudo szabályok egységes konfigurációja.

---

<a name="authentik"></a>

## 1.3 Authentik (Identity Provider & SSO)

Az Authentik a homelab központi **Identity Provider (IdP)** megoldása, amely lehetővé teszi a modern biztonsági protokollok integrációját és a zökkenőmentes, biztonságos beléptetést.

| Alkalmazás | Módszer | Megjegyzés / Stratégia |
| :--- | :--- | :--- |
| **Nextcloud** | OIDC | 
| **Grafana** | OIDC | 
| **Portainer** | OIDC | 
| **Jellyfin** | OIDC | 
| **Teleport** | OIDC | 
| **ArgoCD / Semaphore** | OIDC | 
| **TrueNAS SCALE** | OIDC | 
| **Guacamole** | OIDC | 
| **Prometheus / AdGuard** | Proxy Provider | 
| **Vaultwarden** | Proxy Provider |
| **Switch (TP-Link) UI** | Proxy Provider | 
| **Arr Stack (Radarr, stb.)** | Proxy Provider | 
| **qBittorrent / Gotify** | Proxy Provider |
| **Webmin / PXE / Apt-Cacher**| Proxy Provider | 
| **pfSense** | **LOKÁLIS** | Nem kerül az Authentik mögé. |
| **FreeIPA** | **LOKÁLIS** | Nem függhet Authentiktől. |
| **Proxmox VE 1 & 2** | Elsődlegesen OIDC, de a root@pam megmarad vészhelyzeti elérésnek.. |
| **PBS (Backup Server)** |  Elsődlegesen OIDC, de a root@pam megmarad vészhelyzeti elérésnek. |

### 🔐 Főbb implementációk:
- **Single Sign-On (SSO):** Központosított hitelesítés az összes önállóan hosztolt szolgáltatáshoz. Egyetlen bejelentkezéssel (Passkey-alapú MFA mellett) minden alkalmazás elérhetővé válik 24 órás session időtartamra.
- **OAuth2 & OpenID Connect (OIDC):** Natív integráció a modern alkalmazásokkal a biztonságos, token-alapú hitelesítés érdekében.
- **Forward Auth / Proxy Provider:** Traefik alapú védelem azon legacy szolgáltatásokhoz, amelyek nem rendelkeznek beépített hitelesítéssel. A megoldás biztosítja, hogy az alkalmazások csak érvényes Authentik session birtokában legyenek elérhetőek. Ahol az alkalmazás lehetővé teszi, a lokális hitelesítést kiiktattam a dupla bejelentkezés elkerülése miatt.
- **Passwordless & Break-glass Access:** Elsődlegesen **Passkey (WebAuthn)** alapú, jelszómentes hitelesítést alkalmazok. A kizáródás elleni védelem érdekében **Static Recovery Tokeneket** generáltam, amelyeket biztonságos, garantálva a hozzáférést a hitelesítő eszköz meghibásodása esetén is.

---

<a name="teleport"></a>

## 1.4 Teleport (Access Plane & Zero Trust)

A Teleport biztosítja a biztonságos, infrastruktúra-szintű hozzáférést a homelab erőforrásaihoz, a **Zero Trust** elveit követve.

### Megoldások:
- **SSH & Server Access:** Kiváltottam a statikus SSH-kulcsokat így, és nincs többé ssh kulcs menedzselés.
- **Session Recording & Audit:** Minden SSH és GUI-alapú munkamenet rögzítésre kerül. A tevékenységek visszajátszhatóak és auditálhatóak, ami kritikus a biztonsági incidensek elemzésekor.
- **Unified Access Plane:** Egyetlen felületen (Web UI vagy `tsh` CLI) keresztül érem el a szervereket SSH-n.
- **RBAC (Role-Based Access Control):** Szigorú jogosultságkezelés: a felhasználók csak a számukra kijelölt címkékkel (labels) ellátott erőforrásokhoz férhetnek hozzá.

---

<a name="vaultwarden"></a>

## 1.5 Vaultwarden Password Manager

A Vaultwarden célja: **önálló, self-hosted jelszókezelés a homelabban**.

---

### Funkciók

- **Biztonságos jelszó tárolás**: a homelab összes jelszava **nem kerül ki az internetre**.  
- **Self-hosted**: teljes kontroll a szerver felett.  

---

← [Vissza a Homelab főoldalra](../README_HU.md)











