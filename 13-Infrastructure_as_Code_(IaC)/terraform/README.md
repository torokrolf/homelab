← [Back](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# 📚 Table of Contents

- [1. Using Terraform](#terra)
- [2. Secrets management (SOPS+AGE)](#secrets)
- [3. Template preparation](#templates)
  - [3.1. VM template — cloud-init based](#golden_image)
  - [3.2. LXC template — ansible user + SSH](#lxc_template)
- [4. GitHub Actions pipeline](#pipeline)
- [5. Terraform state management and recovery](#terrastatefajl)
- [6. Importing a VM/LXC](#imp)

---

<a name="terra"></a>

# 1. Using Terraform

The entire Proxmox infrastructure is managed by Terraform — VMs and LXC containers alike. Every resource is cloned from a pre-prepared **golden image** — cloud-init based for VMs, manually prepared templates for LXC containers. Existing, manually created resources were brought under Terraform management using `terraform import`. This ensures every node is consistently managed, reproducible, and rebuildable.

---

<a name="secrets"></a>

# 2. Secrets management (SOPS+AGE)

Sensitive values (Proxmox API token, passwords, SSH keys, MAC addresses) are stored encrypted in `secrets.enc.yaml` using SOPS+AGE. This replaces the `terraform.tfvars` file — no unencrypted secrets file exists in the repository.

---

<a name="templates"></a>

# 3. Template preparation

Two types of templates are maintained: a **VM template** based on cloud-init (used by Terraform for cloning) and an **LXC template** (cloud-init is not supported on LXC, so a separate approach is needed). Both serve the same purpose: a consistent, ready-to-use base state for the Ansible pipeline.

---

<a name="golden_image"></a>

## 3.1. VM template — cloud-init based

A base Ubuntu VM is used to prepare the cloud-init template that Terraform clones for every VM.

### 3.1.1. VM base configuration

All VMs start from a consistent hardware configuration. The **ballooning device** is disabled so that RAM is permanently allocated — this is more reliable than setting identical minimum and maximum memory values.

### 3.1.2. Preparing the golden image

**System update:**

```bash
sudo apt update
sudo apt upgrade -y
```

**Install qemu-guest-agent** — ensures Terraform receives a signal once the VM has booted, instead of waiting indefinitely:

```bash
sudo apt install qemu-guest-agent -y
sudo systemctl enable qemu-guest-agent
sudo systemctl start qemu-guest-agent
sudo systemctl status qemu-guest-agent
```

<img width="779" height="444" alt="screenshot" src="https://github.com/user-attachments/assets/db83215e-5a8b-486b-9765-edd811d0a123" />

**Install and prepare cloud-init:**

```bash
sudo apt install cloud-init -y
sudo cloud-init clean
```

**Clean the machine** — remove SSH host keys, machine-id, and unnecessary packages so that every clone starts as a completely fresh, unique system:

```bash
sudo rm -f /etc/ssh/ssh_host_*
sudo truncate -s 0 /etc/machine-id
sudo apt clean
sudo apt autoremove
```

### 3.1.3. Adding the cloud-init drive

After shutting down the VM, add a **cloud-init drive** and remove the CD-ROM used during installation. The result: one system disk and one cloud-init drive.

<img width="939" height="379" alt="screenshot" src="https://github.com/user-attachments/assets/e04f2ced-55e7-495c-840a-30f5ae1ed112" />

Set the cloud-init network config to DHCP:

<img width="848" height="488" alt="screenshot" src="https://github.com/user-attachments/assets/97744f54-37fe-478a-9192-36cfd4d0b074" />

Regenerate the cloud-init image. The username is `ansible`, the corresponding key is `ansible_target_key`:

<img width="968" height="509" alt="screenshot" src="https://github.com/user-attachments/assets/a107e125-6472-4f9f-bea3-8130ec0a2125" />

### 3.1.4. Converting to template

Right-click → **Convert to template**. Template ID: `8000`, name: `ubuntu-server-22.04.5-cloudinit`.

---

<a name="lxc_template"></a>

## 3.2. LXC template — ansible user + SSH

Since cloud-init is not supported on LXC containers, a custom template is prepared that includes the Ansible-compatible base configuration out of the box.

**The template includes:**
- `rolf` and `ansible` users with SSH key-based login,
- passwordless (`NOPASSWD`) sudo for the `ansible` user,
- unique SSH host keys on every clone (managed by a systemd service),
- a zeroed-out `machine-id`.

**Create users and configure sudo:**

```bash
useradd -m -s /bin/bash rolf
useradd -m -s /bin/bash ansible
usermod -aG sudo rolf
usermod -aG sudo ansible

cat > /etc/sudoers.d/ansible <<'EOF'
ansible ALL=(ALL) NOPASSWD:ALL
EOF
chmod 0440 /etc/sudoers.d/ansible
visudo -cf /etc/sudoers.d/ansible
```

**Upload SSH keys:**

```bash
mkdir -p /home/rolf/.ssh /home/ansible/.ssh
# paste public keys into the authorized_keys files
chmod 700 /home/rolf/.ssh /home/ansible/.ssh
chmod 600 /home/rolf/.ssh/authorized_keys /home/ansible/.ssh/authorized_keys
chown -R rolf:rolf /home/rolf/.ssh
chown -R ansible:ansible /home/ansible/.ssh
```

**Unique SSH host keys per clone** — host keys are removed from the template, and a systemd service regenerates them on the first boot of each clone:

```bash
rm -f /etc/ssh/ssh_host_*

cat > /etc/systemd/system/generate-ssh-host-keys.service <<'EOF'
[Unit]
Description=Generate SSH host keys if missing
Before=ssh.service
ConditionPathExists=!/etc/ssh/ssh_host_ed25519_key

[Service]
Type=oneshot
ExecStart=/usr/bin/ssh-keygen -A
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl enable generate-ssh-host-keys.service
```

**Zero out machine-id** — not deleted, just emptied, since `/var/lib/dbus/machine-id` symlinks to it:

```bash
truncate -s 0 /etc/machine-id
```

**Clean up and convert:**

```bash
apt clean
apt autoremove
```

In the Proxmox UI: right-click → *Convert to template*. LXC containers cloned from this template are immediately usable by the Ansible pipeline — just like VMs provisioned by Terraform.

---

<a name="pipeline"></a>

# 4. GitHub Actions pipeline

Terraform operations are managed by a dedicated workflow (`.github/workflows/proxmox-terraform.yml`), running on the self-hosted runner. The workflow is triggered manually via `workflow_dispatch` with a single parameter:

| Parameter | Value | Description |
|---|---|---|
| `action` | `plan` | Shows what would change, without applying anything |
| `action` | `apply` | Executes the changes (`-auto-approve`) |
| `action` | `import` | Imports an existing Proxmox VM/LXC into state, based on `imported.tf` |
| `action` | `show` | Prints the full Terraform state contents |

**Workflow steps:**

1. **Checkout** — clean clone from the repository.
2. **Secrets decryption** — creates the AGE key file from the `SOPS_AGE_KEY` GitHub Actions Secret, decrypts `secrets.enc.yaml` with it, and reads the values (Proxmox API token, SSH keys, MAC addresses, etc.) into shell variables.
3. **Run Terraform in Docker** — runs the `hashicorp/terraform` image with the `terraform/proxmox-deploy` directory and the state directory (`/home/ansible/terraform-state/proxmox`) mounted in, passing secrets as `TF_VAR_*` environment variables.
   - For `plan` / `apply`: runs the corresponding Terraform command.
   - For `import`: automatically reads the resource name, `node_name`, and `vm_id` from `imported.tf`, then runs `terraform import` with those values.
   - For `show`: prints the state contents so the imported object's data can be copied into `main.tf`.
4. **Cleanup** — deletes the decrypted secrets file and the AGE key, regardless of the step outcome (`if: always()`).

---

<a name="terrastatefajl"></a>

# 5. Terraform state management and recovery

The `main.tf` and other Terraform configs live in GitHub, but `terraform.tfstate` stays on the runner machine (`mgmt-core-01-204`) — the workflow uses and updates it on every run. The state file is currently backed up manually to the NAS.

If `mgmt-core-01-204` is lost, restoring the state file from the NAS is enough for Terraform to immediately resume managing the existing resources. Create the state directory if needed:

```bash
mkdir -p /home/ansible/terraform-state/proxmox
```

Restore the saved file to: `/home/ansible/terraform-state/proxmox/terraform.tfstate`

---

<a name="imp"></a>

# 6. Importing a VM/LXC

To bring an existing, manually created Proxmox VM or LXC under Terraform management, copy the resource block into `imported.tf` with the `node_name` and `vm_id` — use `container` for LXC, `vm` for VMs:

```hcl
resource "proxmox_virtual_environment_container" "adguardhome-222" {
  node_name = "proxmoxom"
  vm_id     = 103
}
```

Running the `import` action in the workflow automatically assembles and executes the `terraform import` command from the above data.

Then run the `show` action to print the state, find the imported object, copy its attributes into `main.tf`, and clear the contents of `imported.tf`.

**Common issue after import:** `plan` may want to recreate the container due to mismatched `unprivileged` or `operating_system` attributes. This can be avoided by ignoring them in a `lifecycle` block:

```hcl
lifecycle {
  ignore_changes = [
    unprivileged,
    operating_system
  ]
}
```

> ⚠️ The trade-off is that Terraform will no longer track changes to these attributes — neither modifications in `main.tf` nor manual changes in Proxmox will be synchronized.

To list available LXC template images on Proxmox:

```bash
pveam list local
```

---

← [Back](../README.md)
