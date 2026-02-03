← [Back to the Homelab main page](../README_HU.md)

[🇬🇧 English](README.md) | [🇭🇺 Magyar](README_HU.md)

---

## 1. APT Cache NG

---

### 1.2 Why I Use It

- I use it for **VM and LXC updates scheduled at 3 AM** via Ansible.  
- Goal: avoid downloading packages separately on every VM/LXC, reducing unnecessary network traffic.  
- The cache proxy stores the packages that have already been requested by a client. If another machine requests the same package and it exists in the cache (a hit), the clients download updates from the APT cache proxy server instead of the internet, saving bandwidth and reducing network load.

It is visible that on some days the hit rate reached **88.26%**: out of **34.05 MB** of traffic, **30.05 MB** was served from the cache. Even on the worst days, out of **996 MB** of traffic, **526 MB** was served from the cache, resulting in a **52% hit rate**. Overall, **6.3 GB** of data was delivered, of which only **2.2 GB** needed to be downloaded from the internet, saving approximately **4 GB** of bandwidth.

<p align="center">
  <img src="https://github.com/user-attachments/assets/d2e4134c-879c-4b88-b3f6-ccb0553a6d9f" alt="APT Cache NG statistics" width="800">
</p>

---

← [Back to the Homelab main page](../README_HU.md)
