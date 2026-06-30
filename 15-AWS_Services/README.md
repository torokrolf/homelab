← [Back to Homelab main page](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# 15. AWS Services — First EC2 Instance

## 📚 Table of Contents

- [1.1 Goal](#goal)
- [1.2 EC2 Instance](#instance)
- [1.3 Installing Docker](#dockerinstall)
- [1.4 Services](#services)
- [1.5 Migrating the Uptime Kuma Config](#uptimemigration)
- [1.6 WireGuard](#wireguard)
- [1.7 Cloudflare Tunnel + Cloudflare Access](#tunnel)
- [1.8 Errors and Their Solutions](#errors)

<a name="goal"></a>

## 1.1 Goal

The homelab's monitoring stack (Uptime Kuma + Gotify) was running on the same physical machine it was monitoring — if the homelab went down, monitoring went down with it.

**Solution:** Deploying a separate Uptime Kuma + Gotify instance on AWS EC2, connected to the homelab via WireGuard VPN, and securely published through Cloudflare Tunnel + Cloudflare Access.

**Architecture overview:**
- EC2 runs Uptime Kuma + Gotify in Docker
- A WireGuard tunnel connects the EC2 instance to the homelab, so EC2 uses the homelab's BIND9 DNS server (for resolving internal hostnames)
- Cloudflare Tunnel exposes the EC2 services publicly, without any open inbound ports
- Cloudflare Access (email + OTP) protects public access so not just anyone can reach it

---

<a name="instance"></a>

## 1.2 EC2 Instance

**Instance type:** `t3.micro` (free tier)
**OS:** Ubuntu
**Region:** eu-central-1 (Frankfurt)
**Storage:** 20 GB gp3

**Creation via AWS CLI:**

```bash
# Create security group
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

This is the running instance.

<img width="1179" height="302" alt="image" src="https://github.com/user-attachments/assets/0e985b99-adf9-4321-a7ec-b9235d393368" />

---

<a name="dockerinstall"></a>

## 1.3 Installing Docker

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

## 1.4 Services (Docker Compose)

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

<a name="uptimemigration"></a>

## 1.5 Migrating the Uptime Kuma Config

Copied the existing Kuma database over via Termius SFTP, then:

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

The WireGuard tunnel serves two purposes:

1. EC2 uses the homelab's BIND9 DNS server, so Uptime Kuma can reach machines by their internal hostnames as well, not just by IP — more precisely, by their public names, but overridden internally.
2. A secure, encrypted channel between the two environments.

---

EC2 instance added as a WireGuard peer.

<img width="1474" height="451" alt="image" src="https://github.com/user-attachments/assets/fea969f9-4ab9-4872-a17e-e8e1029b98bd" />

The EC2 machine pinging the WireGuard server running on pfSense, over the WireGuard IP.

<img width="654" height="109" alt="image" src="https://github.com/user-attachments/assets/a107b078-246d-4896-9d41-994fa1144651" />

<a name="tunnel"></a>

## 1.7 Cloudflare Tunnel + Cloudflare Access

**Why Tunnel instead of open ports?**

In the final setup, no inbound ports are open on the EC2 instance at all. Cloudflare Tunnel establishes an outbound connection to Cloudflare, and services are reached through that — minimizing the attack surface.

**Hosts mapped:**
- `uptimeaws.trkrolf.com` → `localhost:3001`
- `gotifyaws.trkrolf.com` → `localhost:3008`

**Cloudflare Access policy:** Authentik is used for the services running on the homelab, while the EC2 apps use email + OTP authentication.

Cloudflare tunnel running.

<img width="1620" height="671" alt="image" src="https://github.com/user-attachments/assets/5a61631a-0c22-4d90-bc84-0a24fd26dcf2" />

Hosts mapped to the tunnel.

<img width="1596" height="392" alt="image" src="https://github.com/user-attachments/assets/3459b11d-95d8-4c0a-8ba4-4cc75bd726cb" />

Email-based authentication configured for `gotifyaws.trkrolf.com` and `uptimeaws.trkrolf.com`.

<img width="724" height="632" alt="image" src="https://github.com/user-attachments/assets/190527a9-7739-4298-9fac-12627cb281a9" />

---

<a name="errors"></a>

## 1.8 Errors and Their Solutions

Documentation covering errors across the whole infrastructure lives in one shared place, the [17. Errors](../17-Errors/README.md) chapter. The specific issues encountered during the AWS migration:

- [DNS override conflict — homelab BIND9 wildcard clashing with EC2 subdomains](../17-Errors/README.md#dns-override-aws)
- [Cloudflare wildcard certificate limit — third-level subdomain SSL failure](../17-Errors/README.md#cf-wildcard-limit)

---

← [Back to Homelab main page](../README.md)
