# Mount Watchdog: Handling NAS Dependency

This automation runs at the Proxmox host level and monitors the availability of the central storage (TrueNAS). It prevents system-level freezes caused by I/O waits by stopping the VMs, LXCs, and K3s services that depend on the network share when the NAS goes offline — and automatically starts them back up once the NAS becomes available again.

## 📚 Table of Contents

- [Why this is needed](#why)
- [Prerequisites](#prerequisites)
- [Key features and the logic behind them](#logic)
- [Managed technologies and dependencies](#dependencies)
- [Implementation](#implementation)
- [Testing and lessons learned](#testing)

---

## Why this is needed
<a name="why"></a>

On my Proxmox1 node, several VMs and LXCs use the TrueNAS share. It's a real problem when that share becomes unavailable: for example, when the share was down, qBittorrent kept downloading onto the VM's local storage instead — which is unwanted behavior.

The best solution I found is to **stop** the affected LXC and VM in that case — since I follow a one-service-per-VM/LXC principle anyway, this doesn't affect any other service. Once the share becomes available again, I automatically start them back up.

---

## Prerequisites
<a name="prerequisites"></a>

- **Auto-boot disabled** on the VMs/LXCs the script manages (1010, 1101) — Proxmox should not start them at boot, since that's left to the script. The K3s server (1105) is the exception, since that one is toggled at the app level (by scaling pods), not at the VM level, so it can start automatically with Proxmox.
- **Passwordless SSH access** (`ssh-copy-id`) from the Proxmox host to the K3s (and optionally a future Docker) VM, so the script can send `kubectl`/`docker compose` commands unattended.

---

## Key features and the logic behind them
<a name="logic"></a>

### Ping-based fast reaction

The script doesn't test the share itself (SMB/NFS), but **pings** the TrueNAS host directly. The reason is that we don't want to wait for the filesystem to time out or the mount to "hang" (which can take minutes) — a ping immediately signals if TrueNAS is offline, so the script stops the dependent machines before they start freezing on I/O waits. This gives a significantly faster reaction than checking the actual availability of the mount.

### Event-driven operation — State machine

Using the `$STATE_FILE` (`/var/lib/mount-watchdog/nas_status.state`), the script has memory. The systemd timer always runs the script every 30 seconds, but if the ping result matches the previously saved state, the script exits immediately — it doesn't start or stop anything unnecessarily. Without this, it would restart already-running machines on every single 30-second cycle, since the whole script would run through. This way, it only touches the systems when there's been an **actual state change** — no unnecessary SSH logins, no "Docker spam," no log clutter.

### Asynchronous (parallel) control

Using `&` and `wait`, the script doesn't stop/start the machines sequentially (waiting on each other), but fires off all the commands to Proxmox (VM/LXC) and the remote systems (K3s, optionally Docker) at once. This cuts the critical stop/start time down to a fraction.

### The reboot problem and its fix

**What was wrong originally:** If I reboot Proxmox while TrueNAS was available, the state file keeps "UP". After reboot, the script runs, sees that the previous state was UP and the current state is also UP — so there's no change, and it **never starts** the VM/LXC, since they're stopped by default due to auto-boot being disabled. The only way this resolved itself was if I manually stopped TrueNAS (triggering a state change, stopping machines that were already stopped anyway), then made it available again (triggering a DOWN→UP transition that started them).

On the other hand, if TrueNAS was stopped and Proxmox rebooted while the state file had already been written as "DOWN" before shutdown, then after reboot the script sees: currently unavailable, state is also DOWN — no change, does nothing (this is correct). But if Proxmox rebooted due to a power outage and the state file never got written as DOWN (it stayed UP), the script detects a state change (state says UP, reality is DOWN) and stops machines that are already stopped — harmless, but unnecessary.

**The fix:** Delete the state file once after a reboot. To achieve this, the `mount-watchdog.service` includes a 45-second uptime check (`ExecStartPre`) that only deletes the file on the first run (around the 30-second mark, due to the timer's `OnBootSec=30`), and never after that (60s, 90s, etc.). This way the script starts fresh, decides based on the actual current state, detects the DOWN→UP transition, and starts the machines.

**Why exactly 45 seconds:** When Proxmox starts up, the VMs/LXCs are stopped by default (auto-boot disabled), and the script will start them once TrueNAS is available. But the state file still reflects yesterday's (pre-shutdown) state, which is typically "UP". If the script ran at the 30-second mark without deleting the file, it would see: "according to the state everything's running, the NAS is here too, nothing to do" — and the machines would never start. The 45-second threshold is set precisely so that the condition holds true on the first run (~30s: 30 < 45 → delete), but not on the second (~60s: 60 > 45 → no delete). This way the state gets deleted exactly once after a reboot, and afterward the script runs stably, reacting only to actual changes.

### Handling the UNKNOWN state

In reality, three states can occur in the state file: UP, DOWN, and an "unknown" (UNKNOWN) state, which exists when the file simply doesn't exist — e.g. on first run, or after a reboot once we've deleted it. The script handles this as follows:

```bash
PREVIOUS_STATUS="DOWN"
[ -f "$STATE_FILE" ] && PREVIOUS_STATUS=$(cat "$STATE_FILE")
```

If the file is missing, `PREVIOUS_STATUS` defaults to "DOWN" — meaning the script behaves as if the NAS was previously DOWN. If TrueNAS is currently up, this results in a DOWN→UP transition, which starts the VMs and LXCs. This is exactly the desired behavior after a reboot: deleting the state file plus this default together guarantee that the system always aligns with the actual current state, rather than a stale entry.

### systemd.automount — automating late mounts

I use systemd.automount units so that if TrueNAS becomes available later than Proxmox itself starts up, the system will still automatically mount the share the first time something (e.g. Jellyfin) tries to access that path.

Automount doesn't mount the share upfront at boot, but **on-demand** — only when something actually tries to access the mountpoint. If TrueNAS isn't available at boot, the mount simply doesn't attach, but this doesn't cause an error. As soon as TrueNAS comes back and, say, Jellyfin tries to read the media, the kernel signals the automount unit, which mounts the share, and Jellyfin gets the data — all automatically, without intervention.

This is better than a plain `mount.service`: the latter tries to mount at boot, and if the NAS isn't available, it fails with an error. Automount, by contrast, is patient: it mounts the share whenever it becomes available, and the process (Jellyfin, qBittorrent, etc.) already sees the mounted share the moment it first accesses it. The share is managed on the Proxmox host with systemd.automount, and passed through to the LXCs via a bind mount (`mp0`) — since unprivileged LXC containers can't mount a network share directly.

---

## Managed technologies and dependencies
<a name="dependencies"></a>

| Type | ID / Path | Action when the NAS becomes unavailable | Action when the NAS becomes available again |
| :--- | :--- | :--- | :--- |
| **LXC** | 1010 (Jellyfin) | Stop the container (`pct stop`) | Start the container (`pct start`) |
| **VM** | 1101 (PXE/ISO) | Stop the VM (`qm stop`) | Start the VM (`qm start`) |
| **K3s Pods** | `media` namespace — bazarr, prowlarr, qbittorrent, radarr, seerr, sonarr | Scale deployments down to 0 replicas (`kubectl scale`) | Scale deployments up to 1 replica |
| **Docker VM** | *(prepared, not currently active)* | `handle_vm_docker` function, `docker compose stop` over SSH | `docker compose stop` |

---

## Implementation
<a name="implementation"></a>

**`mount-watchdog.sh`**

```bash
#!/bin/bash

# --- LXC CONFIGURATION ---
declare -A LXC_LIST=( [1010]="/mnt/torrent" )

# --- VM CONFIGURATION ---
declare -A VM_LIST=( [1101]="/mnt/pxeiso" )

# Docker VM CONFIGURATION (currently inactive, prepared)
#DOCKER_VM_ID=1102
#DOCKER_VM_IP="192.168.2.230"
#DOCKER_VM_USER="rolf"
#DOCKER_STACK_PATH="/opt/apps-stack/media-stack"

# K3S VM Configuration
K3S_VM_ID=1105
K3S_VM_IP="192.168.2.225"
K3S_VM_USER="rolf"
K3S_NAMESPACE="media"
K3S_APPS="bazarr prowlarr qbittorrent radarr seerr sonarr"

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
GOTIFY_SCRIPT="/usr/local/bin/send-gotify.sh"
NAS_IP="192.168.2.220"
STATE_FILE="/var/lib/mount-watchdog/nas_status.state"

mkdir -p /var/lib/mount-watchdog

# --- TrueNAS status check ---
if ping -c1 -W1 $NAS_IP >/dev/null 2>&1; then
    NAS_ONLINE=0
    CURRENT_STATUS="UP"
else
    NAS_ONLINE=1
    CURRENT_STATUS="DOWN"
fi

PREVIOUS_STATUS="DOWN"
[ -f "$STATE_FILE" ] && PREVIOUS_STATUS=$(cat "$STATE_FILE")

if [ "$CURRENT_STATUS" == "$PREVIOUS_STATUS" ]; then
    exit 0
fi

echo "$(date '+%F %T') - Status change detected: $PREVIOUS_STATUS -> $CURRENT_STATUS"

if [ "$CURRENT_STATUS" == "UP" ]; then
    $GOTIFY_SCRIPT "✅ TrueNAS is available again! Systems are starting."
else
    $GOTIFY_SCRIPT "⚠️ ERROR: TrueNAS unavailable! Dependent systems will be stopped."
fi

# --- Handler functions ---

handle_lxc() {
    local ID=$1
    [ $NAS_ONLINE -eq 0 ] && pct start $ID 2>/dev/null || pct stop $ID 2>/dev/null
}

handle_vm() {
    local ID=$1
    [ $NAS_ONLINE -eq 0 ] && qm start $ID 2>/dev/null || qm stop $ID 2>/dev/null
}

handle_vm_docker() {
    if qm status $DOCKER_VM_ID | grep -q "status: running"; then
        if [ $NAS_ONLINE -eq 0 ]; then
            ssh -o ConnectTimeout=3 ${DOCKER_VM_USER}@${DOCKER_VM_IP} "cd ${DOCKER_STACK_PATH} && docker compose start" >/dev/null 2>&1
        else
            ssh -o ConnectTimeout=3 ${DOCKER_VM_USER}@${DOCKER_VM_IP} "timeout 15s docker compose -f ${DOCKER_STACK_PATH}/docker-compose.yml stop" >/dev/null 2>&1
        fi
    fi
}

handle_k3s_media() {
    if qm status $K3S_VM_ID | grep -q "status: running"; then
        local REPLICAS=0
        [ $NAS_ONLINE -eq 0 ] && REPLICAS=1

        echo "K3S: scaling $K3S_APPS to $REPLICAS replicas..."
        for APP in $K3S_APPS; do
            ssh -o ConnectTimeout=3 ${K3S_VM_USER}@${K3S_VM_IP} "kubectl scale deployment $APP --replicas=$REPLICAS -n $K3S_NAMESPACE" >/dev/null 2>&1 &
        done
    fi
}

# --- RUN IN PARALLEL ---

for ID in "${!LXC_LIST[@]}"; do handle_lxc "$ID" & done
for ID in "${!VM_LIST[@]}"; do handle_vm "$ID" & done
handle_vm_docker &
handle_k3s_media &

wait

echo "$CURRENT_STATUS" > "$STATE_FILE"
echo "$(date '+%F %T') - All operations completed."
exit 0
```

**`mount-watchdog.service`**

```ini
[Unit]
Description=Mount Watchdog (LXC + VM)
After=network.target

[Service]
Type=oneshot
ExecStartPre=/bin/bash -c 'if [ $(awk -F. "{print \$1}" /proc/uptime) -lt 45 ]; then rm -f /var/lib/mount-watchdog/nas_status.state; fi'
ExecStart=/usr/local/bin/mount-watchdog.sh

[Install]
WantedBy=timers.target
```

**`mount-watchdog.timer`**

```ini
[Unit]
Description=Run Mount Watchdog every 30s

[Timer]
OnBootSec=30
OnUnitActiveSec=30
Unit=mount-watchdog.service
AccuracySec=1s

[Install]
WantedBy=timers.target
```

Activation:

```bash
systemctl daemon-reload
systemctl enable --now mount-watchdog.timer
```

* **Gotify integration** — every state change (TrueNAS DOWN→UP or UP→DOWN) triggers an instant push notification to my phone.

<p align="center">
  <img src="https://github.com/user-attachments/assets/a8a0e206-cca0-4a7e-90a7-a69804076534" alt="Description" width="500">
</p>

---

## Testing and lessons learned
<a name="testing"></a>

**Important lesson:** I long thought that one LXC's slow shutdown was a bug, until it turned out this is only how it looks in the Proxmox GUI — as if it hasn't fully stopped, when in reality it's already unreachable. The arrival of the Gotify notification is a clear signal that the stop/start actually happened, regardless of what the Proxmox GUI shows.
