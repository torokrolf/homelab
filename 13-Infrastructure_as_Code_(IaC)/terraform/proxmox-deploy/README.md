← [Back](../../README.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

## 📚 Table of Contents

- [VM configuration used](#vm_felepites)
- [Building the cloud image from a custom VM (golden image)](#golden_image)
- [Using Terraform](#terra)
- [GitHub Actions pipeline](#pipeline)
- [Terraform state file management and recovery](#terrastatefajl)
- [Secrets management (SOPS+AGE)](#secrets)
- [Test: VM creation and deletion](#teszt_vm)
- [Importing a VM/LXC](#imp)
- [Creating an LXC template (ansible user + SSH)](#lxc_template)

---

# VM configuration used (this is the VM I try to use as a base for everything — the default state)
<a name="vm_felepites"></a>

![alt text](images/image9.png)

![alt text](images/image6.png)

![alt text](images/image7.png)

![alt text](images/image8.png)

The ballooning device is some kind of memory reclamation feature, but I disable it so that 12 GB of RAM is permanently allocated. In theory I could achieve this by setting both minimum and maximum memory to 12000, but apparently the reliable way is to simply disable the ballooning device.

![alt text](images/image10.png)

# Building the cloud image from a custom VM (golden image)
<a name="golden_image"></a>

Update and optionally install apps as desired.

```bash
sudo apt update
sudo apt upgrade -y
```

Install and start the qemu-guest-agent, which is important for Terraform — so it doesn't wait indefinitely for a response, but gets a signal back once the VM has booted and the deploy is complete.

```bash
sudo apt install qemu-guest-agent -y
sudo systemctl enable qemu-guest-agent
sudo systemctl start qemu-guest-agent
sudo systemctl status qemu-guest-agent
```

![alt text](images/image.png)

Install cloud-init.

```bash
sudo apt install cloud-init -y
```

Prepare for cloud-init to run on the next boot.

```bash
sudo cloud-init clean
```

Clean the machine so that any new values provided via cloud-init actually take effect — remove SSH host keys, hostname, and unnecessary apt cache.

```bash
sudo rm -f /etc/ssh/ssh_host_*
sudo truncate -s 0 /etc/machine-id
sudo apt clean
sudo apt autoremove
```

Then shut down the VM. Add a cloud-init drive (set it to SCSI, same as the hard disk), and remove the CD-ROM that was used during the initial OS installation. At this point the only drives are the hard disk and the cloud-init drive.

![alt text](images/image2.png)

Set the cloud-init network config to DHCP.

![alt text](images/image3.png)

Click *Regenerate Image* after configuring cloud-init. The username is `ansible` and the corresponding key is `ansible_target_key`.

![alt text](images/image4.png)

Right-click and convert to template. The ID is `8000` and the name will be `ubuntu-server-22.04.5-cloudinit`.

---

<a name="terra"></a>

# Using Terraform

I had a golden image VM, which I imported into Terraform. After importing, I adapted that base resource to create each specific VM — every VM was derived from this golden image.

---

<a name="pipeline"></a>

## GitHub Actions pipeline

The Terraform code and its operations are managed by a dedicated workflow (`.github/workflows/proxmox-terraform.yml`), running on the self-hosted runner. The workflow is triggered via `workflow_dispatch` with a single parameter:

| Parameter | Value | Description |
|---|---|---|
| `action` | `plan` | Shows what would change, without applying anything |
| `action` | `apply` | Executes the changes (`-auto-approve`) |
| `action` | `import` | Imports an existing Proxmox VM/LXC into state, based on `imported.tf` |
| `action` | `show` | Prints the full Terraform state contents |

Workflow steps:

1. **Checkout** — clean clone from the repository.
2. **Secrets decryption** — creates the AGE key file from the `SOPS_AGE_KEY` GitHub Secret, decrypts `secrets.enc.yaml` with it, and reads the values (Proxmox API token, SSH keys, MAC addresses, etc.) into shell variables.
3. **Run Terraform in Docker** — runs the `hashicorp/terraform` image with the `terraform/proxmox-deploy` directory and the state directory (`/home/ansible/terraform-state/proxmox`) mounted in, passing secrets as `TF_VAR_*` environment variables.
   - For `plan` / `apply`: simply runs the corresponding Terraform command.
   - For `import`: automatically reads the resource name, `node_name`, and `vm_id` from `imported.tf`, then runs `terraform import` with those values.
   - For `show`: prints the state contents so I can copy the imported object's data into `main.tf`.
4. **Cleanup** — deletes the decrypted secrets file and the AGE key, regardless of the step outcome (`if: always()`).

---

<a name="terrastatefajl"></a>

## Terraform state file management and recovery

The `main.tf` and Terraform configs live in GitHub, but `terraform.tfstate` stays on the runner machine (`mgmt-core-01-204`) — the workflow uses and updates it on every run.

If `mgmt-core-01-204` is lost, restore the `terraform.tfstate` backed up to the NAS. Create the state directory if needed:

```bash
mkdir -p /home/ansible/terraform-state/proxmox
```

Restore the saved file to: `/home/ansible/terraform-state/proxmox/terraform.tfstate`

---

<a name="secrets"></a>

## Secrets management (SOPS+AGE)

The `terraform.tfvars` used to contain sensitive data (Proxmox API token, passwords, SSH keys, MAC addresses). These are now stored in `secrets.enc.yaml`, encrypted with SOPS+AGE — in the same file and with the same mechanism as the Ansible pipeline.

---

<a name="teszt_vm"></a>

## Test: VM creation and deletion

I added a test VM at the end of `main.tf`:

```hcl
# TEST VM
resource "proxmox_virtual_environment_vm" "test-vm" {
  name      = "test-vm"
  node_name = "proxmoxom"
  vm_id     = 999

  clone {
    vm_id = 8000
    full  = true
  }

  agent {
    enabled = true
  }

  cpu {
    cores = 2
  }

  disk {
    datastore_id = "vm_tarolo"
    interface    = "scsi0"
    size         = 10
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_account {
      keys     = [var.laptopom_pub, var.ansible_target_key_pub]
      password = var.ansible_user_pwd
      username = var.ans_username
    }
  }

  memory {
    dedicated = 2048
  }

  network_device {
    bridge = "vmbr0"
  }
}
```

- Running `plan` detects the new resource.
- Running `apply` creates the VM.
- After removing the resource block, `plan` flags it for deletion and `apply` carries it out.

---

<a name="imp"></a>

## Importing a VM/LXC

To import an existing, manually created Proxmox VM or LXC, copy the resource block into `imported.tf` with the `node_name` and `vm_id` — use `container` for LXC, `vm` for VMs:

```hcl
resource "proxmox_virtual_environment_container" "adguardhome-222" {
  node_name = "proxmoxom"
  vm_id     = 103
}
```

Run the `import` action in the workflow — it automatically assembles and executes the `terraform import` command from the above data.

Then run the `show` action to print the state, find the imported object, copy its attributes into `main.tf`, and clear the contents of `imported.tf`.

**Common issue after import:** `plan` may want to recreate the container due to the `unprivileged` and `template_file_id` attributes. This can be avoided by ignoring them in a `lifecycle` block:

```hcl
lifecycle {
  ignore_changes = [
    unprivileged,
    operating_system
  ]
}
```

> ⚠️ The trade-off is that changes to these attributes — whether in `main.tf` or made manually in Proxmox — will not be tracked by Terraform.

To find the template image path on Proxmox:

```bash
pveam list local
```

---

<a name="lxc_template"></a>

## Creating an LXC template (ansible user + SSH)

Since cloud-init cannot be used with LXC, I create a custom LXC template for fast, repeatable deployments. It automatically includes:

- `rolf` and `ansible` users,
- SSH key-based login for both,
- passwordless (`NOPASSWD`) sudo for the `ansible` user,
- unique SSH host keys on every clone,
- a zeroed-out `machine-id`.

**Users and sudo:**

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

**SSH keys:**

```bash
mkdir -p /home/rolf/.ssh /home/ansible/.ssh
# paste public keys into the authorized_keys files
chmod 700 /home/rolf/.ssh /home/ansible/.ssh
chmod 600 /home/rolf/.ssh/authorized_keys /home/ansible/.ssh/authorized_keys
chown -R rolf:rolf /home/rolf/.ssh
chown -R ansible:ansible /home/ansible/.ssh
```

**Unique SSH host keys per clone:** remove host keys from the template and let a systemd service regenerate them on first boot of each clone:

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

**Zero out machine-id** (don't delete it, just empty it — `/var/lib/dbus/machine-id` symlinks to it):

```bash
truncate -s 0 /etc/machine-id
```

**Clean up, then convert to template:**

```bash
apt clean
apt autoremove
```

Then in the Proxmox UI: right-click → *Convert to template*. LXC containers cloned from this template are immediately usable with Ansible — just like VMs provisioned by Terraform.

← [Back](../../README.md)
