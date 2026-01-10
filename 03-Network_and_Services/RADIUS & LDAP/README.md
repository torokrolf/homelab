← [Back to Homelab Home](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# RADIUS & LDAP

---

## FreeIPA Server as LDAP (CentOS 9)

- Unified user and permission management across the infrastructure.

---

### Implemented Features

- Creation and management of users  
- Configuration of users with sudo privileges

---

## FreeRADIUS Server as RADIUS – Pfsense GUI Authentication

---

### Implemented Features

- **RADIUS login for Pfsense**: logging into the Pfsense GUI using RADIUS authentication  
- **Authentication fallback**: if the RADIUS server is down, login is still possible with a local user  
- **Local and RADIUS usernames/passwords are identical**, so the user does not need to know which authentication method is used  
- **SQL database + PhpMyAdmin**: users and permissions can be conveniently managed via a graphical interface, eliminating the need to edit files or manually log actions; management is done directly through the database

---

← [Back to Homelab Home](../README.md)
