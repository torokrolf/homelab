← [Back to Homelab Home](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# 15. AWS Services — First EC2 Instance

## 🎯 Goal

The homelab monitoring stack (Uptime Kuma + Gotify) ran on the same physical machines it was monitoring — meaning if the homelab went down, the monitoring went down with it. This defeated the purpose of monitoring entirely.

**Solution:** Deploy an external Uptime Kuma + Gotify instance on an AWS EC2 instance, connected to the homelab via WireGuard VPN, and exposed securely via Cloudflare Tunnel + Access.

**Architecture overview:**
- EC2 (Frankfurt / eu-central-1) runs Uptime Kuma + Gotify in Docker
- WireGuard tunnel connects EC2 to the homelab so EC2 can use the homelab's BIND9 DNS server (resolving internal hostnames)
- Cloudflare Tunnel exposes EC2 services publicly — no open ports needed
- Cloudflare Access (email + OTP) gates public access so the services aren't reachable by anyone

---

## 🖥️ EC2 Instance

**Instance type:** `t3.micro` (free tier eligible)  
**OS:** Ubuntu (ami-0303e2e4a29f041a3)  
**Region:** eu-central-1 (Frankfurt)  
**Storage:** 20 GB gp3

**Created with AWS CLI:**

```bash
# Security group
aws ec2 create-security-group \
  --group-name 'launch-wizard-2' \
  --description 'launch-wizard-2 created 2026-06-25' \
  --vpc-id 'vpc-0c86cda3b79915739'

# Allow SSH
aws ec2 authorize-security-group-ingress \
  --group-id 'sg-preview-1' \
  --ip-permissions '{"IpProtocol":"tcp","FromPort":22,"ToPort":22,"IpRanges":[{"CidrIp":"0.0.0.0/0"}]}'

# Launch instance
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

## 🐳 Docker Installation

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

## 📦 Services (Docker Compose)

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

## 🔁 Uptime Kuma Config Migration

Copy the existing Kuma database via Termius SFTP, then:

```bash
docker compose down
mv /home/ubuntu/kuma.db /opt/uptime/data/kuma.db
chown 1000:1000 /opt/uptime/data/kuma.db
chmod 664 /opt/uptime/data/kuma.db
docker compose up -d
docker logs uptime-kuma -f
```

> **Note:** Only migrate after everything else is configured (Cloudflare, WireGuard, DNS) — at that point the EC2 username also changes to the homelab user and everything carries over cleanly.

---

## 🌐 WireGuard — EC2 ↔ Homelab

The WireGuard tunnel serves two purposes:

1. EC2 uses the homelab's BIND9 DNS server → Uptime Kuma can reach internal hosts by name (e.g. `proxmox.lan`), not just by IP.
2. Encrypted, secure channel between the two environments.

> Detailed WireGuard config: [04-Remote_Access](../04-Remote_Access/README.md)

---

## ☁️ Cloudflare Tunnel + Access

**Why Tunnel instead of open ports?**

No inbound ports are open on the EC2 instance in the final setup — the Cloudflare Tunnel establishes an outbound connection to Cloudflare, and services are reached through that. This minimizes the attack surface.

**Assigned hostnames:**
- `uptimeaws.trkrolf.com` → `localhost:3001`
- `gotifyaws.trkrolf.com` → `localhost:3008`

**Cloudflare Access policy:** email + OTP authentication, without Authentik — Authentik handles SSO for the homelab's Traefik services; the EC2 apps use a simpler, separate protection layer.

---

## 🐛 Issues & Solutions

### 1. DNS Override Conflict (on homelab WiFi)

**Symptom:** `uptimeaws.trkrolf.com` failed to load on home network, but worked fine on mobile data.

**Cause:** The homelab BIND9 has a `*.trkrolf.com` wildcard override pointing everything to the local Traefik — so EC2 subdomains never reached Cloudflare.

**Fix:** Created exceptions in AdGuard Home for the EC2 subdomains so they resolve to the Cloudflare proxy IP instead of hitting the BIND9 override.

```bash
# Verify correct resolution
nslookup gotifyaws.trkrolf.com 1.1.1.1
ipconfig /flushdns
```

---

### 2. Cloudflare Wildcard Certificate Limit

**Symptom:** `uptime.aws.trkrolf.com` — SSL Handshake Failure.

**Cause:** Cloudflare Universal SSL (free plan) only covers single-level wildcards (`*.trkrolf.com`). The subdomain `uptime.aws.trkrolf.com` is third-level, so it falls outside the certificate's scope.

**Fix:** Renamed subdomains to single-level: `uptimeaws.trkrolf.com`, `gotifyaws.trkrolf.com` — these are fully covered by `*.trkrolf.com`.

> **Lesson learned:** On Cloudflare's free plan, always design with single-level subdomains if using a wildcard cert — otherwise Total TLS (paid) is required.

---

### 3. Edge SSL vs Origin SSL

**Question:** If I already have a Let's Encrypt cert on the homelab, why do I need a Cloudflare cert too?

**Explanation:**

| | Edge cert (Cloudflare) | Origin cert (Let's Encrypt) |
|---|---|---|
| **Scope** | Browser ↔ Cloudflare | Cloudflare ↔ your server |
| **Issued by** | Cloudflare (automatic) | Let's Encrypt / own CA |
| **Without it** | Browser throws a red error | Only Flexible SSL possible |

- **Cloudflare Tunnel:** The tunnel itself encrypts traffic between EC2 and Cloudflare, so `Flexible` mode is acceptable here.
- **Homelab Traefik:** Has a Let's Encrypt cert, so `Full (Strict)` mode is used — the entire path is encrypted end-to-end.

---

## 🔒 Closing Open Ports

After testing, the Gotify (3008) and Uptime Kuma (3001) ports were removed from the EC2 security group — they are only accessible via Cloudflare Tunnel.

| Port | Status | Notes |
|------|--------|-------|
| 22 (SSH) | Open | Administration |
| 3001 (Uptime Kuma) | Closed | Cloudflare Tunnel only |
| 3008 (Gotify) | Closed | Cloudflare Tunnel only |

---

← [Back to Homelab Home](../README.md)