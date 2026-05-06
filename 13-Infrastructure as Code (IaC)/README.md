---

## 1.1 Infrastructure as Code (IaC) - Terraform & Provisioning

I provision and manage the virtual infrastructure using **Terraform**, ensuring rapid environment reproducibility and consistency across the lab.

*   **Provisioning Workflow:** Virtual Machines are deployed based on a custom-built **Golden Image** (Ubuntu 22.04 Proxmox template). Terraform performs a **Full Clone** of this template, ensuring that new instances are completely independent of the base image.
*   **Resource Management:** Hardware parameters (CPU, RAM, Disk, Network) are defined declaratively in the code. This allows for precise scaling of nodes based on their specific workload — such as memory-intensive **k3s servers** versus lightweight **gateways**.
*   **Cloud-Init Automation:** Using the Terraform `initialization` block, I dynamically inject security credentials (SSH keys) and system settings. This process completely eliminates manual configuration: instances reach a "ready-to-use" state immediately after the first boot, prepared for further configuration via Ansible.

---