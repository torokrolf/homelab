← [Vissza](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

# 📚 Tartalomjegyzék

- [1. Terraform használata](#terra)
- [2. Secrets kezelése (SOPS+AGE)](#secrets)
- [3. Template készítés](#templates)
  - [3.1. VM template — cloud-init alapon](#golden_image)
  - [3.2. LXC template — ansible user + SSH](#lxc_template)
- [4. GitHub Actions pipeline](#pipeline)
- [5. Terraform state kezelése és visszaállítása](#terrastatefajl)
- [6. VM/LXC importálása](#imp)

---

<a name="terra"></a>

# 1. Terraform használata

A Proxmox infrastruktúra teljes egészében Terraform felügyelet alatt áll, VM-ek és LXC konténerek egyaránt. Minden erőforrás előre elkészített **golden image**-ből lesz klónozva, VM-ekhez cloud-init alapú, LXC-khez manuálisan előkészített template formájában. A kézzel létrehozott már meglévő erőforrásokat `terraform import`-tal vontam Terraform felügyelete alá. Így minden csomópont egységesen kezelhető, reprodukálható és újraépíthető.

---

<a name="secrets"></a>

# 2. Secrets kezelése (SOPS+AGE)

Az érzékeny adatok (Proxmox API token, jelszavak, SSH kulcsok, MAC-címek) a `secrets.enc.yaml` fájlban, SOPS+AGE-vel titkosítva kerülnek verziókövetés alá. A `terraform.tfvars` fájlt ezzel váltottam ki: nincs titkosítatlan secrets fájl a repóban.

---

<a name="templates"></a>

# 3. Template készítés

Kétféle template-et tartok karban: egy **VM template**-et cloud-init alapon (Terraform használja klónozáshoz) és egy **LXC template**-et (cloud-init LXC-n nem támogatott, ezért külön megközelítés szükséges). Mindkettő célja ugyanaz: az Ansible pipeline számára azonnal használható, egységes alapállapot.

---

<a name="golden_image"></a>

## 3.1. VM template — cloud-init alapon

Egy alap Ubuntu VM-ből készítem el a cloud-init alapú template-et, amelyből a Terraform minden VM-et klónoz.

### 3.2.1. VM alapkonfiguráció

Az összes VM egységes hardverkonfigurációból indul. A **ballooning device**-t kikapcsolom, hogy a RAM fixen legyen kiosztva, ez megbízhatóbb, mint a minimum/maximum memória azonos értékre állítása.

### 3.1.2. A golden image előkészítésének 

**Rendszerfrissítés:**

```bash
sudo apt update
sudo apt upgrade -y
```

**qemu-guest-agent telepítése** — ez biztosítja, hogy a Terraform visszajelzést kapjon, amint a VM elindult, és ne várakozzon:

```bash
sudo apt install qemu-guest-agent -y
sudo systemctl enable qemu-guest-agent
sudo systemctl start qemu-guest-agent
sudo systemctl status qemu-guest-agent
```

<img width="779" height="444" alt="kép" src="https://github.com/user-attachments/assets/db83215e-5a8b-486b-9765-edd811d0a123" />

**cloud-init telepítése és előkészítése:**

```bash
sudo apt install cloud-init -y
sudo cloud-init clean
```

**A gép tisztítása** — SSH host kulcsok, machine-id és felesleges csomagok törlése, hogy a klónok teljesen friss, egyedi gépként induljanak:

```bash
sudo rm -f /etc/ssh/ssh_host_*
sudo truncate -s 0 /etc/machine-id
sudo apt clean
sudo apt autoremove
```

### 3.1.3. cloud-init drive hozzáadása

A VM leállítása után hozzáadok egy **cloud-init drive-ot** és eltávolítom a telepítéshez használt CD-ROM meghajtót. A végeredmény: egy rendszerlemez és egy cloud-init drive.

<img width="939" height="379" alt="kép" src="https://github.com/user-attachments/assets/e04f2ced-55e7-495c-840a-30f5ae1ed112" />

A cloud-init hálózati beállítását DHCP-re állítom:

<img width="848" height="488" alt="kép" src="https://github.com/user-attachments/assets/97744f54-37fe-478a-9192-36cfd4d0b074" />

Újragenerálom a cloud-init image-et. A felhasználónév `ansible`, a hozzá tartozó kulcs neve `ansible_target_key`:

<img width="968" height="509" alt="kép" src="https://github.com/user-attachments/assets/a107e125-6472-4f9f-bea3-8130ec0a2125" />

### 3.1.4. Konvertálás template-té

Jobb klikk → **Convert to template**. A template ID-ja `8000`, neve: `ubuntu-server-22.04.5-cloudinit`.

---

<a name="lxc_template"></a>

## 3.2. LXC template — ansible user + SSH

Az LXC konténerekhez cloud-init nem használható, ezért saját template-et készítek, amely automatikusan tartalmazza az Ansible-kompatibilis alapkonfigurációt.

**A template tartalma:**
- `rolf` és `ansible` felhasználók SSH kulcsos belépéssel,
- az `ansible` usernek jelszó nélküli (`NOPASSWD`) sudo jog,
- minden klónon egyedi SSH host key-ek (systemd service gondoskodik róla),
- nullázott `machine-id`.

**Felhasználók és sudo létrehozása:**

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

**SSH kulcsok feltöltése:**

```bash
mkdir -p /home/rolf/.ssh /home/ansible/.ssh
# public key-ek bemásolása az authorized_keys fájlokba
chmod 700 /home/rolf/.ssh /home/ansible/.ssh
chmod 600 /home/rolf/.ssh/authorized_keys /home/ansible/.ssh/authorized_keys
chown -R rolf:rolf /home/rolf/.ssh
chown -R ansible:ansible /home/ansible/.ssh
```

**Egyedi SSH host key-ek klónonként** — a template-ből törlöm a host key-eket, és egy systemd service gondoskodik arról, hogy minden klón első indulásakor újragenerálja azokat:

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

**Machine-id nullázása** — nem törlöm, csak kiürítem, mivel a `/var/lib/dbus/machine-id` erre symlinkel:

```bash
truncate -s 0 /etc/machine-id
```

**Takarítás és konvertálás:**

```bash
apt clean
apt autoremove
```

Proxmox felületén: jobb klikk → *Convert to template*. Az így elkészült template-ből klónozott LXC konténerek azonnal elérhetők az Ansible pipeline számára — ugyanúgy, mint a Terraformmal létrehozott VM-ek.

---

<a name="pipeline"></a>

# 4. GitHub Actions pipeline

A Terraform műveleteket egy dedikált workflow vezérli (`.github/workflows/proxmox-terraform.yml`), amely a self-hosted runneren fut. A workflow manuálisan indítható (`workflow_dispatch`), egyetlen paraméterrel:

| Paraméter | Érték | Leírás |
|---|---|---|
| `action` | `plan` | Megmutatja mi változna, tényleges módosítás nélkül |
| `action` | `apply` | Végrehajtja a változásokat (`-auto-approve`) |
| `action` | `import` | Meglévő Proxmox VM/LXC importálása a state-be, az `imported.tf` alapján |
| `action` | `show` | Kiírja a teljes Terraform state tartalmát |

**A workflow lépései:**

1. **Checkout** — tiszta clone a repóból.
2. **Secrets dekódolása** — a `SOPS_AGE_KEY` GitHub Actions Secretből előállítja az AGE kulcsfájlt, azzal dekódolja a `secrets.enc.yaml`-t, majd a benne lévő értékeket (Proxmox API token, SSH kulcsok, MAC-címek stb.) shell változókba olvassa.
3. **Terraform futtatása Dockerben** — a `hashicorp/terraform` image-et futtatja, a `terraform/proxmox-deploy` mappát és a state könyvtárat (`/home/ansible/terraform-state/proxmox`) mountolva bele, a titkos értékeket `TF_VAR_*` környezeti változóként átadva.
   - `plan` / `apply` esetén lefuttatja a megfelelő Terraform parancsot.
   - `import` esetén az `imported.tf`-ből automatikusan kiolvassa a resource nevét, a `node_name`-et és a `vm_id`-t, majd ezekkel futtatja a `terraform import`-ot.
   - `show` esetén kiírja a state tartalmát — innen másolom át az importált objektum adatait a `main.tf`-be.
4. **Takarítás** — a dekódolt secrets fájl és az AGE kulcs törlése, a lépés kimenetelétől függetlenül (`if: always()`).

---

<a name="terrastatefajl"></a>

# 5. Terraform state kezelése és visszaállítása

A `main.tf` és a többi Terraform konfiguráció GitHubon él, de a `terraform.tfstate` a futtató gépen (`mgmt-core-01-204`) marad — a workflow minden futáskor felhasználja, majd frissíti. A state fájlt jelenleg kézileg mentem a NAS-ra.

Ha az `mgmt-core-01-204` elvész, a NAS-ról visszaállított state fájllal a Terraform azonnal újra felügyelheti a meglévő erőforrásokat. A state könyvtárat szükség esetén létre kell hozni:

```bash
mkdir -p /home/ansible/terraform-state/proxmox
```

A mentett fájlt vissza kell másolni ide: `/home/ansible/terraform-state/proxmox/terraform.tfstate`

---

<a name="imp"></a>

# 6. VM/LXC importálása

Meglévő, kézzel létrehozott Proxmox VM vagy LXC Terraform felügyelet alá vonásához az `imported.tf`-be kell másolni a resource típusát a `node_name` és `vm_id` megadásával, LXC esetén `container`, VM esetén `vm` típussal:

```hcl
resource "proxmox_virtual_environment_container" "adguardhome-222" {
  node_name = "proxmoxom"
  vm_id     = 103
}
```

A workflow `import` action-jét futtatva automatikusan összeállítja és végrehajtja a `terraform import` parancsot a fenti adatokból.

Ezután a `show` action-nel kiíratom a state tartalmát, megkeresem az importált objektumot, az adatait átmásolom a `main.tf`-be, majd az `imported.tf` tartalmát törlöm.

**Gyakori probléma importálás után:** a `plan` az `unprivileged` és az `operating_system` attribútumok eltérése miatt újra akarja létrehozni a konténert. Ez elkerülhető, ha ezeket a `lifecycle` blokkban figyelmen kívül hagyatjuk:

```hcl
lifecycle {
  ignore_changes = [
    unprivileged,
    operating_system
  ]
}
```

> ⚠️ Ez azt jelenti, hogy ezeket az attribútumokat a Terraform a jövőben sem fogja nyomon követni — sem `main.tf`-beli módosítás, sem kézi Proxmox-szintű változtatás nem kerül szinkronizálásra.

A Proxmoxon elérhető LXC template image-ek listázása:

---

← [Vissza](../README_HU.md)
