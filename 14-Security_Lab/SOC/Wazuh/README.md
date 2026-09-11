← [Back](../../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# Security Operations (SIEM & Detection)

---

## 📚 Table of Contents

- [Architecture & Installation](#architecture)
- [Authentication Event Monitoring (SSH & sudo)](#auth)
- [Command Execution Detection (auditd)](#auditd)
- [SSH Brute Force — Active Response Demonstration](#bruteforce)
- [File Integrity Monitoring (FIM)](#fim)
- [Malware Detection (FIM + VirusTotal)](#virustotal)
- [Vulnerability Detection](#vuln)
- [Log Retention](#logretention)

---

<a name="architecture"></a>

## Architecture & Installation

The **Wazuh manager** was installed natively via the official install script on a dedicated Ubuntu VM, with agents deployed to every Linux and Windows machine to be monitored.

```bash
curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh
sudo bash wazuh-install.sh -a
```

After installation, I can log into the web interface using the generated admin password. On the agent side, the Wazuh dashboard generates a platform- and host-specific install command.

<img width="945" height="413" alt="image" src="https://github.com/user-attachments/assets/d6d00d4e-ce43-4886-b610-c8340428fa3d" />

---

<a name="auth"></a>

## Authentication Event Monitoring (SSH & sudo)

Based on the built-in ruleset, I identified and validated the following rule IDs with real login attempts:

**SSH (Linux):**

| Rule ID | Meaning |
|---|---|
| 5710 | Non-existent username |
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

Login attempt via SSH with a non-existent user. This is what showed up under Wazuh events.

<img width="612" height="53" alt="image" src="https://github.com/user-attachments/assets/9a2115b5-c2ac-475e-baeb-d66226d951fa" />

SSH login with an existing user. This is what showed up under Wazuh events.

<img width="623" height="59" alt="image" src="https://github.com/user-attachments/assets/518ed23d-d3d0-4d08-8ff9-180eeaed195b" />

SSH login with an existing user but a wrong password generated this event.

<img width="629" height="54" alt="image" src="https://github.com/user-attachments/assets/ccc8b52d-ecd4-47fc-9ee9-fe06e9530574" />

This is logged on the very first successful root login of the system's lifetime.

<img width="945" height="58" alt="image" src="https://github.com/user-attachments/assets/17b3ecb1-006e-44bf-a11b-6b018e9966e7" />

Every subsequent successful root login then shows up like this.

<img width="945" height="52" alt="image" src="https://github.com/user-attachments/assets/61162a41-351b-4b2b-9d3c-de1aee91f71c" />

One or two failed passwords generate this event.

<img width="945" height="51" alt="image" src="https://github.com/user-attachments/assets/995ef402-6ac5-48c7-8a22-b7cb173e74a4" />

Three failed passwords result in the following event.

<img width="945" height="50" alt="image" src="https://github.com/user-attachments/assets/dcfd5217-6236-4e2c-bb22-a071ba758e62" />

---

<a name="auditd"></a>

## Command Execution Detection (auditd)

Syslog only sees application-level logs (e.g. what the SSH daemon itself writes). **auditd**, by contrast, operates at the kernel level, so it captures events that an application log would never show — most importantly, **what commands the root user actually executes**.

Installing auditd on the monitored machine.

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

A custom audit rule on the client, logging every root-initiated process execution event (both 64-bit and 32-bit):

```
-a exit,always -F euid=0 -F arch=b64 -S execve -k audit-wazuh-c
-a exit,always -F euid=0 -F arch=b32 -S execve -k audit-wazuh-c
```

Load the rules: `sudo augenrules --load`

### Noise Filtering with a Custom Rule

auditd logs every root execve call, including routine background commands that aren't relevant (`sed`, `df`, `systemctl`, etc.).
The image below shows that even though I only ran `netstat` on the client, many other unrelated commands also showed up.

<img width="1207" height="587" alt="image" src="https://github.com/user-attachments/assets/fec136e8-5a71-4986-aac8-40fb40dfb131" />

I filtered this on the server side with two chained custom rules:

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

Now, when I run `netstat` on the client, no unrelated commands pop up alongside it — only `netstat` itself.

<img width="1203" height="91" alt="image" src="https://github.com/user-attachments/assets/5c4ab93c-41e0-4c70-89d2-1612f5ec7e4f" />

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

<img width="945" height="286" alt="image" src="https://github.com/user-attachments/assets/e03e0386-985a-4e0e-b425-0bb1fbcb3de1" />

**4. Automated response:** the alert triggers Active Response, which blocks the attacker's IP on the target's firewall (iptables). During the test, neither ping nor SSH was reachable from the attacking machine toward the target.

```bash
sudo iptables -L INPUT -v -n --line-numbers
```

**5. Automatic unblock:** once the configured 180-second timeout expires, Wazuh automatically removes the firewall rule.

<img width="945" height="236" alt="image" src="https://github.com/user-attachments/assets/6ce3d35f-95e0-4f08-8174-c5f9304154f0" />

---

<a name="fim"></a>

## File Integrity Monitoring (FIM)

The default FIM configuration checks the designated directories every 12 hours (`<frequency>43200</frequency>`) (`/etc`, `/usr/bin`, `/usr/sbin`, `/bin`, `/sbin`, `/boot`), which isn't real-time but conserves resources.

For `/root` I configured real-time, fully detailed monitoring on the client:

```xml
<directories check_all="yes" report_changes="yes" realtime="yes">/root</directories>
```

**Tested and validated event types:**

| Rule ID | Event |
|---|---|
| 554 | File created |
| 550 | File content modified (checksum change) |
| 553 | File deleted |

Every case was validated with a real test: creating a file in the monitored directory, modifying its content, changing permissions, and changing ownership — in each case the dashboard showed exactly what changed, including the before/after values.

Creating the file.

<img width="671" height="737" alt="image" src="https://github.com/user-attachments/assets/869e5857-2b99-4cf9-8f75-904a4120ab30" />

Modifying the file's content.

<img width="808" height="565" alt="image" src="https://github.com/user-attachments/assets/d49c503d-0773-4046-a2e0-ddabfc04a470" />

Changing permissions.

<img width="625" height="280" alt="image" src="https://github.com/user-attachments/assets/14fb2996-6ced-4d36-bb3d-225db6166e8a" />

Changing ownership.

<img width="599" height="354" alt="image" src="https://github.com/user-attachments/assets/3bdb83b7-9fe5-4de6-bd96-c74753168f5e" />

Deleting the file.

<img width="862" height="218" alt="image" src="https://github.com/user-attachments/assets/dd5c1da7-50a0-496a-860e-d73e3fc2767f" />

---

<a name="virustotal"></a>

## Malware Detection (FIM + VirusTotal)

An automated malware screening workflow built on top of File Integrity Monitoring: if a new file appears or changes in a monitored directory (in this case `/root`), Wazuh computes the file's hash and queries the **VirusTotal API** to check whether that hash matches a known malicious file.

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

<img width="945" height="187" alt="image" src="https://github.com/user-attachments/assets/7b0abb22-0b5e-4317-83d8-b460de07e75d" />

Wazuh detected the new file, queried VirusTotal, and generated an alert flagging it as known malicious code.

<img width="945" height="21" alt="image" src="https://github.com/user-attachments/assets/bb20ee4d-8275-4f95-a294-cfecacb17934" />

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

<img width="945" height="580" alt="image" src="https://github.com/user-attachments/assets/75052f48-a99a-4fdb-83b4-b0634f1dfa75" />

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

← [Back](../../README.md)
