← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# 15. AWS Services — Első EC2 Instance

## Cél

A homelab monitorozó stack (Uptime Kuma + Gotify) ugyanazon a fizikai gépen futott, amit monitorozott — tehát ha a homelab leállt, a monitorozás is leállt vele. Ez teljesen értelmetlen.

**Megoldás:** Egy külső Uptime Kuma + Gotify instance telepítése AWS EC2-re, WireGuard VPN-en keresztül összekötve a homelabbal, és Cloudflare Tunnel + Access által biztonságosan publikálva.

**Architektúra áttekintés:**
- EC2 (Frankfurt / eu-central-1) futtatja az Uptime Kumát + Gotifyt Dockerben
- WireGuard tunnel köti össze az EC2-t a homelabbal, így az EC2 a homelab BIND9 DNS szerverét használja (belső hostnevek feloldásához)
- Cloudflare Tunnel teszi elérhetővé az EC2 szolgáltatásait publikusan — nyitott portok nélkül
- Cloudflare Access (email + OTP) védi a publikus elérést, hogy ne férjen hozzá bárki

---

## EC2 Instance

**Instance típus:** `t3.micro` (free tier)  
**OS:** Ubuntu (ami-0303e2e4a29f041a3)  
**Régió:** eu-central-1 (Frankfurt)  
**Tárhely:** 20 GB gp3

**Létrehozás AWS CLI-vel:**

```bash
# Security group létrehozása
aws ec2 create-security-group \
  --group-name 'launch-wizard-2' \
  --description 'launch-wizard-2 created 2026-06-25' \
  --vpc-id 'vpc-0c86cda3b79915739'

# SSH engedélyezése
aws ec2 authorize-security-group-ingress \
  --group-id 'sg-preview-1' \
  --ip-permissions '{"IpProtocol":"tcp","FromPort":22,"ToPort":22,"IpRanges":[{"CidrIp":"0.0.0.0/0"}]}'

# Instance indítása
aws ec2 run-instances \
  --image-id 'ami-0303e2e4a29f041a3' \
  --instance-type 't3.micro' \
  --key-name 'ssh' \
  --block-device-mappings '{"DeviceName":"/dev/sda1","Ebs":{"Encrypted":false,"DeleteOnTermination":true,"Iops":3000,"VolumeSize":20,"VolumeType":"gp3","Throughput":125}}' \
  --network-interfaces '{"AssociatePublicIpAddress":true,"DeviceIndex":0,"Groups":["sg-preview-1"]}' \
  --tag-specifications '{"ResourceType":"instance","Tags":[{"Key":"Name","Value":"FirstEC2"}]}' \
  --metadata-options '{"HttpEndpoint":"enabled","HttpPutResponseHopLimit":2,"HttpTokens":"required"}' \
  --count '1'
```

---

## Docker telepítése

```bash
apt update && apt install -y curl gnupg lsb-release ca-certificates

mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

---

## Szolgáltatások (Docker Compose)

### Gotify — `/opt/gotify/docker-compose.yml`

```yaml
services:
  gotify:
    image: gotify/server:2.9.1
    container_name: gotify
    restart: always
    ports:
      - "3008:80"
    environment:
      - TZ=Europe/Budapest
      - GOTIFY_DEFAULTUSER_PASS=admin
      - GOTIFY_SERVER_EXTERNALURL=https://gotifyaws.trkrolf.com
    volumes:
      - "./data:/app/data"
```

### Uptime Kuma — `/opt/uptime/docker-compose.yml`

```yaml
services:
  uptime-kuma:
    image: louislam/uptime-kuma:latest
    container_name: uptime-kuma
    restart: always
    ports:
      - "3001:3001"
    volumes:
      - ./data:/app/data
    networks:
      - monitor-net

networks:
  monitor-net:
    driver: bridge
```

### Cloudflare Tunnel — `/opt/cloudflare/docker-compose.yml`

```yaml
services:
  cloudflared:
    image: cloudflare/cloudflared:latest
    container_name: cloudflared
    restart: unless-stopped
    environment:
      TUNNEL_TOKEN: <token>
    command: tunnel --no-autoupdate run
```

---

## Uptime Kuma konfig átmigrálása

Meglévő Kuma adatbázis átmásolása Termius SFTP-vel, majd:

```bash
docker compose down
mv /home/ubuntu/kuma.db /opt/uptime/data/kuma.db
chown 1000:1000 /opt/uptime/data/kuma.db
chmod 664 /opt/uptime/data/kuma.db
docker compose up -d
docker logs uptime-kuma -f
```

> **Fontos:** A migrációt csak akkor érdemes elvégezni, ha már minden be van állítva (Cloudflare, WireGuard, DNS), mert ekkorra az EC2-es felhasználónév is megváltozik a homelabos felhasználóra és minden átmentődik.

---

## WireGuard — EC2 ↔ Homelab

A WireGuard tunnel két célt szolgál:

1. Az EC2 a homelab BIND9 DNS szerverét használja → az Uptime Kuma belső neveken (pl. `proxmox.lan`) is el tudja érni a gépeket, nem csak IP-n.
2. Biztonságos, titkosított csatorna a két környezet között.

> Részletes WireGuard konfig: [04-Remote_Access](../04-Remote_Access/README_HU.md)

---

## Cloudflare Tunnel + Access

**Miért Tunnel és nem nyitott portok?**

Az EC2-n semmilyen bejövő port nem volt nyitva a végleges beállításban — a Cloudflare Tunnel kimenő kapcsolatot épít fel a Cloudflare-rel, és ezen keresztül érhetők el a szolgáltatások. Ez minimalizálja a támadási felületet.

**Hozzárendelt hostok:**
- `uptimeaws.trkrolf.com` → `localhost:3001`
- `gotifyaws.trkrolf.com` → `localhost:3008`

**Cloudflare Access policy:** email + OTP hitelesítés, Authentik **nélkül** — az Authentik a homelab Traefik-es szolgáltatásaihoz van, az EC2-es appokhoz külön, egyszerűbb védelem kell.

---

## Hibák és megoldásuk

### 1. DNS override konfliktus (homelabos wifin)

**Tünet:** `uptimeaws.trkrolf.com` otthoni hálón nem töltött be, mobilneten igen.

**Ok:** A homelab BIND9-ben `*.trkrolf.com` wildcard override van, ami mindent a lokális Traefik-re irányít — így az EC2-es aldomainek sem értek el Cloudflare-ig.

**Megoldás:** AdGuard Home-ban kivétel létrehozása az EC2-es aldomainekre, hogy azok ne az override-olt BIND9-hez menjenek, hanem Cloudflare proxy IP-re oldódjanak fel.

```bash
# Ellenőrzés: a helyes IP-re oldódik-e fel
nslookup gotifyaws.trkrolf.com 1.1.1.1
ipconfig /flushdns
```

---

### 2. Cloudflare wildcard tanúsítvány limit

**Tünet:** `uptime.aws.trkrolf.com` — SSL Handshake Failure.

**Ok:** A Cloudflare Universal SSL (ingyenes csomag) csak egyszintű wildcardot fed le (`*.trkrolf.com`). A `uptime.aws.trkrolf.com` harmadik szintű aldomain, így kiesik a hatókörből.

**Megoldás:** Aldomainek átnevezése egyszintűre: `uptimeaws.trkrolf.com`, `gotifyaws.trkrolf.com` — ezeket a `*.trkrolf.com` wildcard már lefedi.

> **Tanulság:** Cloudflare ingyenes csomagnál mindig egyszintű aldomaineket érdemes tervezni, ha wildcard certet használsz — különben Total TLS (fizetős) kell.

---

### 3. Edge SSL vs Origin SSL

**Kérdés:** Ha van Let's Encrypt certem a homelabban, miért kell még Cloudflare cert is?

**Magyarázat:**

| | Edge cert (Cloudflare) | Origin cert (Let's Encrypt) |
|---|---|---|
| **Hol érvényes** | Böngésző ↔ Cloudflare | Cloudflare ↔ szerver |
| **Ki adja ki** | Cloudflare automatikusan | Let's Encrypt / saját CA |
| **Nélküle mi történik** | Böngésző piros hibát dob | Csak Flexible SSL lehetséges |

- **Cloudflare Tunnel esetén:** A tunnel maga titkosítja a forgalmat EC2 és Cloudflare között, így ott `Flexible` mód is elfogadható.
- **Homelab Traefik esetén:** Van Let's Encrypt cert, ezért `Full (Strict)` mód van beállítva — a teljes útvonal titkosított.

---

## Portok lezárása

A tesztelés után a Gotify és Uptime Kuma portokat bezártam az EC2 security groupból — ezek Cloudflare Tunnelen keresztül érhetők el, nyitott portokra nincs szükség.

| Port | Állapot | Megjegyzés |
|------|---------|------------|
| 22 (SSH) | Nyitva | Adminisztrációhoz |
| 3001 (Uptime Kuma) | Zárva | Csak Cloudflare Tunnelen keresztül |
| 3008 (Gotify) | Zárva | Csak Cloudflare Tunnelen keresztül |

---

← [Vissza a Homelab főoldalra](../README_HU.md)