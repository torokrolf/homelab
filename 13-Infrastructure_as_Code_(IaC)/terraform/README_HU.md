← [Back](../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# 📚 Table of Contents

- [1. Using Terraform](#terra)
- [2. Secrets Management (SOPS+AGE)](#secrets)
- [3. Template Creation](#templates)
  - [3.1. VM Template — cloud-init based](#golden_image)
  - [3.2. LXC Template — ansible user + SSH](#lxc_template)
- [4. GitHub Actions Pipeline](#pipeline)
- [5. Terraform State Management and Recovery](#terrastatefajl)
- [6. Importing VM/LXC](#imp)

---

<a name="terra"></a>

# 1. Using Terraform

The entire Proxmox infrastructure is managed by Terraform, covering both VMs and LXC containers. Every resource is cloned from a pre-built **golden image** — cloud-init based for VMs, and a manually prepared template for LXC containers. Existing manually created resources were brought under Terraform management using `terraform import`. This ensures every node is uniformly managed, reproducible, and rebuildable.

---

<a name="secrets"></a>

# 2. Secrets Management (SOPS+AGE)

Sensitive data (Proxmox API token, passwords, SSH keys, MAC addresses) is stored in the `secrets.enc.yaml` file, encrypted with SOPS+AGE and committed to version control. This replaces the `terraform.tfvars` file — there are no unencrypted secrets files in the repository.

---

<a name="templates"></a>

# 3. Template Creation

Two types of templates are maintained: a **VM template** based on cloud-init (used by Terraform for cloning) and an **LXC template** (cloud-init is not supported on LXC, so a separate approach is required). Both serve the same purpose: providing a uniform, immediately usable base state for the Ansible pipeline.

---

<a name="golden_image"></a>

## 3.1. VM Template — cloud-init based

The cloud-init template is built from a base Ubuntu VM, from which Terraform clones every VM.

### 3.1.1. Base VM Configuration

All VMs start from a uniform hardware configuration. The **ballooning device** is disabled so that RAM is allocated as a fixed amount — this is more reliable than setting minimum and maximum memory to the same value.

### 3.1.2. Preparing the Golden Image

**System update:**

```bash
sudo apt update
sudo apt upgrade -y
```

**Installing qemu-guest-agent** — ensures Terraform receives feedback as soon as the VM has started, without unnecessary waiting:

```bash
sudo apt install qemu-guest-agent -y
sudo systemctl enable qemu-guest-agent
sudo systemctl start qemu-guest-agent
sudo systemctl status qemu-guest-agent
```

<img width="779" height="444" alt="image" src="https://github.com/user-attachments/assets/db83215e-5a8b-486b-9765-edd811d0a123" />

**Installing and preparing cloud-init:**

```bash
sudo apt install cloud-init -y
sudo cloud-init clean
```

**Cleaning the machine** — removing SSH host keys, machine-id, and unnecessary packages so that clones boot as completely fresh, unique machines:

```bash
sudo rm -f /etc/ssh/ssh_host_*
sudo truncate -s 0 /etc/machine-id
sudo apt clean
sudo apt autoremove
```

### 3.1.3. Adding the cloud-init Drive

After shutting down the VM, a **cloud-init drive** is added and the CD-ROM drive used during installation is removed. The result: one system disk and one cloud-init drive.

<img width="939" height="379" alt="image" src="https://github.com/user-attachments/assets/e04f2ced-55e7-495c-840a-30f5ae1ed112" />

The cloud-init network configuration is set to DHCP:

<img width="848" height="488" alt="image" src="https://github.com/user-attachments/assets/97744f54-37fe-478a-9192-36cfd4d0b074" />

The cloud-init image is regenerated. The username is `ansible`, and the associated key name is `ansible_target_key`:

<img width="968" height="509" alt="image" src="https://github.com/user-attachments/assets/a107e125-6472-4f9f-bea3-8130ec0a2125" />

### 3.1.4. Converting to Template

Right-click → **Convert to template**. The template ID is `8000`, name: `ubuntu-server-22.04.5-cloudinit`.

---

<a name="lxc_template"></a>

## 3.2. LXC Template — ansible user + SSH

Cloud-init cannot be used with LXC containers, so a custom template is prepared that automatically includes an Ansible-compatible base configuration.

**Template contents:**
- `rolf` and `ansible` users with SSH key-based login,
- passwordless (`NOPASSWD`) sudo rights for the `ansible` user,
- unique SSH host keys on every clone (managed by a systemd service),
- zeroed `machine-id`.

**Creating users and sudo configuration:**

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

**Uploading SSH keys:**

```bash
mkdir -p /home/rolf/.ssh /home/ansible/.ssh
# copy public keys into the authorized_keys files
chmod 700 /home/rolf/.ssh /home/ansible/.ssh
chmod 600 /home/rolf/.ssh/authorized_keys /home/ansible/.ssh/authorized_keys
chown -R rolf:rolf /home/rolf/.ssh
chown -R ansible:ansible /home/ansible/.ssh
```

**Unique SSH host keys per clone** — host keys are deleted from the template, and a systemd service ensures that every clone regenerates them on first boot:

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

**Zeroing machine-id** — rather than deleting it, it is truncated, since `/var/lib/dbus/machine-id` symlinks to it:

```bash
truncate -s 0 /etc/machine-id
```

**Cleanup and conversion:**

```bash
apt clean
apt autoremove
```

In the Proxmox UI: right-click → *Convert to template*. LXC containers cloned from this template are immediately accessible to the Ansible pipeline — just like VMs created with Terraform.

---

<a name="pipeline"></a>

# 4. GitHub Actions Pipeline

Terraform operations are orchestrated by a dedicated workflow (`.github/workflows/proxmox-terraform.yml`), running on a self-hosted runner. The workflow is triggered manually (`workflow_dispatch`) with a single parameter:

| Parameter | Value | Description |
|---|---|---|
| `action` | `plan` | Shows what would change, without applying anything |
| `action` | `apply` | Applies the changes (`-auto-approve`) |
| `action` | `import` | Imports an existing Proxmox VM/LXC into the state, based on `imported.tf` |
| `action` | `show` | Prints the full Terraform state contents |

**Workflow steps:**

1. **Checkout** — a clean clone from the repository.
2. **Secrets decryption** — the `SOPS_AGE_KEY` GitHub Actions Secret is used to produce the AGE key file, which decrypts `secrets.enc.yaml`; the contained values (Proxmox API token, SSH keys, MAC addresses, etc.) are then loaded into shell variables.
3. **Running Terraform in Docker** — the `hashicorp/terraform` image is run, with the `terraform/proxmox-deploy` directory and the state directory (`/home/ansible/terraform-state/proxmox`) mounted in, and secrets passed as `TF_VAR_*` environment variables.
   - For `plan` / `apply`, the corresponding Terraform command is executed.
   - For `import`, the resource name, `node_name`, and `vm_id` are automatically parsed from `imported.tf`, and `terraform import` is run with those values.
   - For `show`, the state contents are printed — this is then used to copy the imported object's data into `main.tf`.
4. **Cleanup** — the decrypted secrets file and AGE key are deleted, regardless of the step's outcome (`if: always()`).

---

<a name="terrastatefajl"></a>

# 5. Terraform State Management and Recovery

`main.tf` and other Terraform configs live on GitHub, but `terraform.tfstate` remains on the runner machine (`mgmt-core-01-204`) — the workflow reads and updates it on every run. The state file is currently backed up manually to a NAS.

If `mgmt-core-01-204` is lost, restoring the state file from the NAS allows Terraform to immediately resume managing the existing resources. The state directory must be created if it doesn't exist:

```bash
mkdir -p /home/ansible/terraform-state/proxmox
```

The backed-up file must be restored to: `/home/ansible/terraform-state/proxmox/terraform.tfstate`

---

<a name="imp"></a>

# 6. Importing VM/LXC

To bring an existing, manually created Proxmox VM or LXC under Terraform management, copy the resource definition into `imported.tf` with the `node_name` and `vm_id` specified — use `container` for LXC and `vm` for VMs:

```hcl
resource "proxmox_virtual_environment_container" "adguardhome-222" {
  node_name = "proxmoxom"
  vm_id     = 103
}
```

Running the workflow with the `import` action automatically assembles and executes the `terraform import` command from the above data.

Afterwards, the `show` action prints the state contents — locate the imported object, copy its data into `main.tf`, and clear the contents of `imported.tf`.

**Common issue after import:** `plan` may want to recreate the container due to mismatches in the `unprivileged` and `operating_system` attributes. This can be avoided by ignoring them in the `lifecycle` block:

```hcl
lifecycle {
  ignore_changes = [
    unprivileged,
    operating_system
  ]
}
```

> ⚠️ This means Terraform will no longer track these attributes in the future — changes made in `main.tf` or directly in Proxmox will not be synchronized.

Listing available LXC template images on Proxmox:

---

← [Back](../README.md)
