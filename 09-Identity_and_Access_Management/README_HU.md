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

## 1.3 Authentik

Az Authentik a homelab központi **Identity Provider (IdP)** megoldása, amely lehetővé teszi a modern biztonsági protokollok integrációját és az egységesített beléptetést.

### 🔐 Főbb implementációk:
- **Single Sign-On (SSO):** Központosított hitelesítés az összes önállóan hosztolt (self-hosted) szolgáltatáshoz. Egyetlen bejelentkezéssel (MFA mellett) minden alkalmazás elérhetővé válik a session lejártáig.
- **OAuth2 & OpenID Connect (OIDC):** Natív integráció a modern alkalmazásokkal a biztonságos token-alapú hitelesítés érdekében.
- **Forward Auth / Proxy Provider:** Olyan legacy szolgáltatások védelme, amelyek nem rendelkeznek beépített hitelesítéssel. A hálózati forgalom egy központi proxy-n fut keresztül, amely kényszeríti az Authentik session meglétét.
- **MFA:** Többtényezős hitelesítés (WebAuthn, TOTP) kényszerítése a kritikus szolgáltatások elérése előtt.

<a name="teleport"></a>

---

## 1.4 Teleport (Access Plane & Zero Trust)

A Teleport biztosítja a biztonságos, infrastruktúra-szintű hozzáférést a homelab erőforrásaihoz, a **Zero Trust** elveit követve.

### 🛡️ Megoldások:
- **SSH & Server Access:** Kiváltottam a statikus SSH-kulcsokat rövid élettartamú, X.509 tanúsítványalapú hitelesítéssel. Nincs többé `authorized_keys` menedzselés.
- **Session Recording & Audit:** Minden SSH és GUI-alapú munkamenet rögzítésre kerül. A tevékenységek visszajátszhatóak és auditálhatóak, ami kritikus a biztonsági incidensek elemzésekor.
- **Unified Access Plane:** Egyetlen felületen (Web UI vagy `tsh` CLI) keresztül érem el a Linux szervereket, Kubernetes klasztereket és belső adatbázisokat, VPN használata nélkül.
- **RBAC (Role-Based Access Control):** Szigorú jogosultságkezelés: a felhasználók csak a számukra kijelölt címkékkel (labels) ellátott erőforrásokhoz férhetnek hozzá.

<a name="vaultwarden"></a>

---

## 1.5 Vaultwarden Password Manager

A Vaultwarden célja: **önálló, self-hosted jelszókezelés a homelabban**.

---

### 🔐 Funkciók

- **Biztonságos jelszó tárolás**: a homelab összes jelszava **nem kerül ki az internetre**.  
- **Self-hosted**: teljes kontroll a szerver felett.  

---

← [Vissza a Homelab főoldalra](../README_HU.md)











