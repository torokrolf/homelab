← [Vissza a Homelab főoldalra](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# 15. AWS Services — Első EC2 Instance

## 📚 Tartalomjegyzék

- [1.1 Cél](#cel)
- [1.2 EC2 instance](#instance)
- [1.3 Docker telepítése](#dockertelepites)
- [1.4 Szolgáltatások](#services)
- [1.5 Uptime Kuma konfig migrálása](#uptimemigralas)
- [1.6 Wireguard](#wireguard)
- [1.7 Cloudflare Tunnel + Cloudflare Access](#tunnel)
- [1.8 Hibák és megoldásuk](#hibak)


<a name="cel"></a>

## 1.1 Cél

A homelab monitorozó stack (Uptime Kuma + Gotify) ugyanazon a fizikai gépen futott, amit monitorozott, ha a homelab leállt, a monitorozás is leállt vele. 

**Megoldás:** Egy külső Uptime Kuma + Gotify instance telepítése AWS EC2-re, WireGuard VPN-en keresztül összekötve a homelabbal, és Cloudflare Tunnel + Access által biztonságosan publikálva.

**Architektúra áttekintés:**
- EC2 futtatja az Uptime Kumát + Gotifyt Dockerben
- WireGuard tunnel köti össze az EC2-t a homelabbal, így az EC2 a homelab BIND9 DNS szerverét használja (belső hostnevek feloldásához)
- Cloudflare Tunnel teszi elérhetővé az EC2 szolgáltatásait publikusan, nyitott portok nélkül
- Cloudflare Access (email + OTP) védi a publikus elérést, hogy ne férjen hozzá bárki

---

<a name="instance"></a>

## 1.2 EC2 Instance

**Instance típus:** `t3.micro` (free tier)  
**OS:** Ubuntu 
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

<a name="dockertelepites"></a>

## 1.3 Docker telepítése

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

<a name="services"></a>

## 1.4 Szolgáltatások (Docker Compose)

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
      - GOTIFY_DEFAULTUSER_PASS=password
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

<a name="uptimemigralas"></a>

## 1.5 Uptime Kuma konfig migrálása

Meglévő Kuma adatbázis átmásolása Termius SFTP-vel, majd:

```bash
docker compose down
mv /home/ubuntu/kuma.db /opt/uptime/data/kuma.db
chown 1000:1000 /opt/uptime/data/kuma.db
chmod 664 /opt/uptime/data/kuma.db
docker compose up -d
docker logs uptime-kuma -f
```

---

<a name="wireguard"></a>

## 1.6 WireGuard — EC2 ↔ Homelab

A WireGuard tunnel két célt szolgál:

1. Az EC2 a homelab BIND9 DNS szerverét használja, az Uptime Kuma belső neveken is el tudja érni a gépeket, nem csak IP-n, pontosabban publikus neveken de overrideolva azt.
2. Biztonságos, titkosított csatorna a két környezet között.

---

<a name="tunnel"></a>

## 1.7 Cloudflare Tunnel + Cloudflare Access

**Miért Tunnel és nem nyitott portok?**

Az EC2-n semmilyen bejövő port nem volt nyitva a végleges beállításban, a Cloudflare Tunnel kimenő kapcsolatot épít fel a Cloudflare-rel, és ezen keresztül érhetők el a szolgáltatások. Ez minimalizálja a támadási felületet.

**Hozzárendelt hostok:**
- `uptimeaws.trkrolf.com` → `localhost:3001`
- `gotifyaws.trkrolf.com` → `localhost:3008`

**Cloudflare Access policy:** az Authentik a homelab-on futó  szolgáltatásokhozhoz van, az EC2-es appokhoz email + OTP hitelesítés-t használok

---

<a name="hibak"></a>

## 1.8 Hibák és megoldásuk

A teljes infrastruktúrát érintő hibakezelési dokumentáció egy közös helyen, a [17. Hibák és hibaelhárítás](../17-Errors/README_HU.md) fejezetben található. Az AWS migráció során felmerült specifikus problémák:

- [DNS override konfliktus — homelab BIND9 wildcard ütközés EC2 aldomainekkel](../17-Errors/README_HU.md#dns-override-aws)
- [Cloudflare wildcard tanúsítvány limit — harmadik szintű aldomain SSL hiba](../17-Errors/README_HU.md#cf-wildcard-limit)

---

← [Vissza a Homelab főoldalra](../README_HU.md)
