← [Back to Homelab main page](../../../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Security Operations (SIEM & Detection)

The goal is to practice the core workflows of a Security Operations Center (SOC): log-based intrusion detection, rule writing, incident investigation, and automated defensive response, built on the **Wazuh** SIEM/XDR platform.

---

## 📚 Table of Contents

- [Architecture & Installation](#architecture)
- [How Wazuh Processes a Log (Decoder → Rule)](#decoder)
- [Authentication Event Monitoring (SSH & sudo)](#auth)
- [Command Execution Detection (auditd)](#auditd)
- [SSH Brute Force — Active Response Demonstration](#bruteforce)
- [File Integrity Monitoring (FIM)](#fim)
- [Malware Detection (FIM + VirusTotal)](#virustotal)
- [Vulnerability Detection](#vuln)
- [Security Compliance Auditing (CIS Benchmark)](#cis)
- [Log Retention](#logretention)
- [Current Status & Roadmap](#roadmap)

---

<a name="architecture"></a>

## Architecture & Installation

The **Wazuh manager** was installed natively via the official install script on a dedicated Ubuntu VM (version 4.14), with agents deployed to every Linux and Windows machine to be monitored.

```bash
curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh
sudo bash wazuh-install.sh -a
```

A successful install is confirmed by the generated admin password, which I stored securely. On the agent side, the Wazuh dashboard generates a platform-specific install command (a shell command for Linux, an admin PowerShell command for Windows) that already includes the manager's IP and the agent's name.

> **Installation note:** a failed or interrupted install (typically due to insufficient disk space — at least 10 GB free is required) leaves behind manager files that must be manually cleaned up before retrying (`dpkg` cache, `/var/ossec`, `wazuh-install-files`), otherwise the script fails again.

Both the manager and agent configuration live at the same path: `/var/ossec/etc/ossec.conf`

---

<a name="decoder"></a>

## How Wazuh Processes a Log (Decoder → Rule)

Incoming raw logs are unstructured text on their own. Wazuh turns them into evaluable, alertable events in two steps:

**1. Decoder** — extracts and standardizes fields, regardless of source platform (a Cisco switch log and an Ubuntu sshd log end up in the same standardized shape after processing).

**2. Rule** — evaluates the standardized fields and decides whether the event should trigger an alert, and at what severity.

**Example — raw SSH log:**
```
Jun 15 14:00:00 server sshd[123]: Failed password for root from 192.168.1.50 port 22
```

**Decoder output:**
| Field | Value |
|---|---|
| user | root |
| srcip | 192.168.1.50 |
| protocol | ssh |
| action | failed |

**Rule evaluation:** the combination of `failed` action and `root` user matches a prohibited pattern in the ruleset → an alert is generated.

### Rule Hierarchy (Inheritance)

The built-in SSH rules demonstrate the efficiency of Wazuh's rule system well:

- **Rule 5700** (`level="0" noalert="1"`) — a parent/container rule that only groups logs (`decoded_as: sshd`) and does not alert on its own.
- **Rule 5701** (`if_sid: 5700`, `level="8"`) — only evaluates logs that already passed through 5700, and if the pattern matches (e.g. `Bad protocol version identification`), it overrides the parent's severity and fires an alert.

This gives two benefits: **efficiency** (the decoder match doesn't need to be re-evaluated by every child rule), and **modularity** (new child rules can be added against the existing parent at any time without redefining the base filter).

- Built-in rules location: `/var/ossec/ruleset/rules` — I never edit this, since it gets overwritten on update.
- Custom rules location: `/var/ossec/etc/rules/local_rules.xml` — this is what I extend.
- Rules can be tested both via GUI and CLI (`Ruleset test`) before going live.

---

<a name="auth"></a>

## Authentication Event Monitoring (SSH & sudo)

Based on the built-in ruleset, I identified and validated the following rule IDs with real login attempts:

**SSH (Linux):**

| Rule ID | Meaning |
|---|---|
| 5710 | Non-existent username (e.g. blind `admin`/`root` guessing attempts) |
| 5760 | Existing username, wrong password |
| 5715 | Successful SSH login — always worth monitoring in production |

**sudo (Linux):**

| Rule ID | Meaning |
|---|---|
| 5401 | Wrong sudo password (1st–2nd attempt) |
| 5404 | Wrong sudo password 3 times — lockout |
| 5403 | First-ever successful sudo use for a given user |
| 5402 | Normal, routine successful sudo use |

Every event type was validated with a real test (SSH with both existing and non-existent usernames, correct and incorrect sudo passwords, 3 consecutive wrong attempts), confirming on the dashboard that the correct rule ID fired each time.

---

<a name="auditd"></a>

## Command Execution Detection (auditd)

Syslog only sees application-level logs (e.g. what the SSH daemon itself writes). **auditd**, by contrast, operates at the kernel level, so it captures events that an application log would never show — most importantly, **what commands the root user actually executes**.

```bash
apt install auditd -y
```

Adding the log source to the agent config:

```xml
<localfile>
    <log_format>audit</log_format>
    <location>/var/log/audit/audit.log</location>
</localfile>
```

A custom audit rule logging every root-initiated process execution event (both 64-bit and 32-bit):

```
-a exit,always -F euid=0 -F arch=b64 -S execve -k audit-wazuh-c
-a exit,always -F euid=0 -F arch=b32 -S execve -k audit-wazuh-c
```

| Parameter | Meaning |
|---|---|
| `-a exit,always` | log the result at the end of every system call |
| `-F euid=0` | only watch events triggered by root (UID 0) |
| `-S execve` | the system call used when a program/command is launched |
| `-k audit-wazuh-c` | a tag that makes the source easily searchable on the Wazuh side |

Load the rules: `sudo augenrules --load`

### Noise Filtering with a Custom Rule

auditd logs every root execve call, including routine background commands that aren't relevant (`sed`, `df`, `systemctl`, etc.). I filtered this with two chained custom rules:

```xml
<rule id="100005" level="7">
    <if_sid>80700</if_sid>
    <field name="audit.key">audit-wazuh-c</field>
    <description>Audit: Privileged root command executed: $(audit.exe)</description>
    <group>audit_command</group>
</rule>

<rule id="100006" level="0">
    <if_sid>100005</if_sid>
    <field name="audit.exe">/usr/bin/sed|/usr/bin/dash|/usr/bin/sort|/usr/bin/last|/usr/bin/df|/usr/bin/systemctl|/usr/bin/sleep|/usr/bin/date|/usr/bin/mountpoint|/usr/bin/ping</field>
    <description>Audit: Noise discarded.</description>
</rule>
```

Rule `100005` alerts at level 7 on every privileged root command, while `100006` — inheriting from `100005` — sets the whitelisted, harmless commands down to level 0, so they don't show up as dashboard alerts but remain searchable in the logs.

---

<a name="bruteforce"></a>

## SSH Brute Force — Active Response Demonstration

This test demonstrates the full detection chain, from simulating the attack to the automated firewall block.

**1. Configuring Active Response on the manager** — when rule 5763 (SSH brute force) fires, it runs `firewall-drop` on the specified agent, blocking for 180 seconds:

```xml
<active-response>
    <command>firewall-drop</command>
    <location>defined-agent</location>
    <agent_id>005</agent_id>
    <rules_id>5763</rules_id>
    <timeout>180</timeout>
</active-response>
```

**2. Simulating the attack** from a Kali Linux VM, using Hydra against the target's SSH port:

```bash
sudo gunzip /usr/share/wordlists/rockyou.txt.gz
hydra -t 4 -l root -P /usr/share/wordlists/rockyou.txt 192.168.2.200 ssh
```

**3. Detection:** the built-in logic identifies 8 failed login attempts within 120 seconds from the same source as brute force (rule 5763, level 10). A 60-second "ignore" window prevents every subsequent attempt from re-triggering an alert.

**4. Automated response:** the alert triggers Active Response, which blocks the attacker's IP on the target's firewall (iptables). During the test, neither ping nor SSH was reachable from the attacking machine toward the target.

```bash
sudo iptables -L INPUT -v -n --line-numbers
```

**5. Automatic unblock:** once the configured 180-second timeout expires, Wazuh automatically removes the firewall rule.

**Important technical detail:** the `firewall-drop` script operates directly on `iptables`, so the protection works even if `ufw` is disabled — `ufw` is, in practice, just a wrapper around `iptables`.

---

<a name="fim"></a>

## File Integrity Monitoring (FIM)

The default FIM configuration checks the designated directories every 12 hours (`<frequency>43200</frequency>`) (`/etc`, `/usr/bin`, `/usr/sbin`, `/bin`, `/sbin`, `/boot`), which isn't real-time but conserves resources.

For `/root` — the most sensitive location on the system — I configured real-time, fully detailed monitoring:

```xml
<directories check_all="yes" report_changes="yes" realtime="yes">/root</directories>
```

| Parameter | Effect |
|---|---|
| `realtime="yes"` | immediate detection, no waiting for the next scan cycle |
| `report_changes="yes"` | shows not just that something changed, but exactly *what* changed |
| `check_all="yes"` | checks size, permissions, owner, and content hash all together |

**Tested and validated event types:**

| Rule ID | Event |
|---|---|
| 554 | File created |
| 550 | File content modified (checksum change) |
| 553 | File deleted |

Every case was validated with a real test: file creation (`touch`), content modification, permission change, and ownership change — in each case the dashboard showed the exact before/after value (e.g. `rw-r--r--` → modified permission, or `root` → `rolf` ownership change).

---

<a name="virustotal"></a>

## Malware Detection (FIM + VirusTotal)

An automated malware screening workflow built on top of FIM: if a new file appears or changes in a monitored directory (in this case `/root`), Wazuh computes the file's hash and queries the **VirusTotal API** to check whether that hash matches a known malicious file.

**1. Targeted rules** for FIM events occurring in `/root` (inheriting from the base 550/554 rules):

```xml
<rule id="100200" level="7">
    <if_sid>550</if_sid>
    <field name="file">/root</field>
    <description>File modified in /root directory.</description>
</rule>

<rule id="100201" level="7">
    <if_sid>554</if_sid>
    <field name="file">/root</field>
    <description>File added to /root directory.</description>
</rule>
```

**2. VirusTotal integration** in the manager config, bound to the two rule IDs above:

```xml
<integration>
    <name>virustotal</name>
    <api_key>***</api_key>
    <rule_id>100200,100201</rule_id>
    <alert_format>json</alert_format>
</integration>
```

**3. Validation with a real test malware sample:** downloading the EICAR test file (an industry-standard, harmless file that every antivirus recognizes as malware) into the monitored directory:

```bash
curl -Lo eicar.com https://secure.eicar.org/eicar.com
```

Wazuh detected the new file, queried VirusTotal, and generated an alert flagging it as known malicious code.

---

<a name="vuln"></a>

## Vulnerability Detection

Wazuh's built-in Vulnerability Detection module cross-references the software inventory on each agent against known CVE databases, flagging affected components in near real time.

**Real-world case:** detection of a critical Google Chrome vulnerability (CVSS **9.6**), affecting every install up to version 149.0.7827.103. The detailed CVSS breakdown:

| Metric | Value | Meaning |
|---|---|---|
| Attack Complexity | Low | doesn't require special access or skill to exploit |
| Attack Vector | Network | remotely exploitable over the internet |
| Confidentiality Impact | High | access to sensitive data (passwords, browsing history) |
| Integrity Impact | High | system or browser files can be modified |
| Availability Impact | High | the system/browser can be crashed or frozen |

My own system fell within the affected version range (149.0.7827.102); after updating Chrome, the vulnerability automatically disappeared from the Wazuh dashboard.

---

<a name="cis"></a>

## Security Compliance Auditing (CIS Benchmark)

The **Configuration Assessment** module audits system configuration against the CIS (Center for Internet Security) industry standard. A scan on a Windows 11 Enterprise client against the **CIS Microsoft Windows 11 Enterprise Benchmark v3.0.0** showed 23% compliance (113 checks passed, 360 failed), with a detailed breakdown of which settings deviate from the recommended secure configuration.

---

<a name="logretention"></a>

## Log Retention

Wazuh's own service logs (`ossec.log`, `api.log`, `cluster.log`, `active-responses.log`) are managed with logrotate:

```
{
    daily
    rotate 30
    missingok
    notifempty
    compress
    delaycompress
    maxsize 100M
    dateext
    dateformat -%Y%m%d
    copytruncate
}
```

Daily rotation, 30-day retention, 100 MB daily size cap — if that cap is exceeded on a given day, the system creates additional files for that day, which proportionally shortens the effective retention window (e.g. at 150 MB/day, 2 files are created per day, so the 30 files cover roughly 15 days).

Cleanup of alert/archive logs (`*.gz`) older than 30 days is handled by a cron job:

```bash
0 0 * * * find /var/ossec/logs/alerts/ -name "*.gz" -type f -mtime +30 -exec rm -f {} \;
0 0 * * * find /var/ossec/logs/archives/ -name "*.gz" -type f -mtime +30 -exec rm -f {} \;
```

---

<a name="roadmap"></a>

## Current Status & Roadmap

- [x] Native Wazuh manager installation, agents on Linux and Windows clients
- [x] Understanding and practical testing of decoder/rule logic and hierarchy
- [x] SSH and sudo authentication events identified and validated with real tests
- [x] auditd integration for root command execution monitoring, with a custom noise filter
- [x] End-to-end SSH brute force demonstration (attack → detection → Active Response → automatic unblock)
- [x] Real-time File Integrity Monitoring with validated event types
- [x] Malware detection via FIM + VirusTotal API integration, validated with EICAR
- [x] Vulnerability Detection demonstrated with a real CVE
- [x] CIS Benchmark-based Configuration Assessment
- [ ] Integrate Suricata (IDS/IPS) on pfSense, forward alerts into Wazuh
- [ ] Nessus Essentials-based vulnerability scanning with before/after comparison
- [ ] Joint Wazuh + Suricata incident correlation (SOC use case)
- [ ] Build a custom incident report template for real-world events

---

← [Back to Homelab main page](../../../README.md)