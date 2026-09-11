# Ram usage teszt

```bash
stress --vm 1 --vm-bytes $(free -m | awk '/^Mem:/{printf "%d", $2*0.85}')M --vm-hang 0 --timeout 600s
```

# CPU usage teszt

```bash
stress --cpu $(nproc) --timeout 720s
```
