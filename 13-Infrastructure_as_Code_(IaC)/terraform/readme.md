## 📚 Tartalomjegyzék

- [Alkalmazott VM felépítése](#vm_felepites)
- [Saját VM-ből fejlesztem le a cloud-image-t (golden image)](#golden_image)
- [Terraform használata](#terra)
---

# Alkalmazott VM felépítése (ezt a vm-et próbálom használni mindnehez, ez az alapállapot)
<a name="vm_felepites"></a>

![alt text](images/image9.png)

![alt text](images/image6.png)

![alt text](images/image7.png)

![alt text](images/image8.png)

Ballooning device valami memóriafelszabadásra van de én kikapcsolom hogy 12gb memória fixen ki legyen osztva neki. Ezt elvileg elérhetem ha minimum és maximum memóriának itt 12000-et állítok be de állítólag ez a tuti ha ezt a ballooning device-et kikapcsolom.

![alt text](images/image10.png)

# Saját VM-ből fejlesztem le a cloud-image-t (golden image)
<a name="golden_image"></a>

Frissítek, esetleg telepítek appokat tetszés szerint.

```sudo apt update```

```sudo apt upgrade -y```

Qemu-guest-agent telepítése és indítása, ami terraformhoz fontos lesz, hogy ne végtelenségig várjon a visszajelzésre, hanem ha elindul a vm akkor vissza tudjon szólni hogy renden, végetért a deploy.

```sudo apt install qemu-guest-agent -y```

```sudo systemctl enable qemu-guest-agent ```

```sudo systemctl start qemu-guest-agent```

```sudo systemctl status qemu-guest-agent```

![alt text](images/image.png)

Cloud initet feltelepítem.

```sudo apt install cloud-init -y```

Felkészítem, hogy a következő újraindításkor induljon el a cloud-init.

```sudo cloud-init clean```

Felkészítem a gépet, hogy a cloud initben ha új dolgokat adok majd meg, akkor azok érvényesüljenek is, azaz ssh-kat törlöm, hostname-et, meg hogy minél tisztább legyen az apt felesleges dolgait.

```sudo rm -f /etc/ssh/ssh_host_*```

```sudo truncate -s 0 /etc/machine-id```

```sudo apt clean```

```sudo apt autoremove```

Ezután leállítom a vm-et. Hozzáadok egy cloudinit drive-ot, scsi legyen, mert a hard disk is az, cdromot meg eltávolítottam innen, amit még telepítésnél használtam, mikor feltettem a vm-et. Tehát most itt csak hard disk maradt, cloudi nit drive és ennyi a meghajtó.

![alt text](images/image2.png)

Cloud init-nél dhcp-re állítom.

![alt text](images/image3.png)

És regenerate image, miután beállítottam így a cloud-init-et. A usernév ansible és a hozzá tartozó kulcsom neve az ansible_target_key.

![alt text](images/image4.png)

Jobb klikk és konvertálom template-é. 8000 az id és neve ubuntu-server-22.04.5-cloudinit lesz.

---

<a name="terra"></a>
# Terraform használata

Volt tehát egy golden imagem VM-nek, és ezt én importáltam terraform-ba, miután importáltam ezt az importált golden image-t szerkesztgettem hogy az adott vm létrejöjjön, és minden vm-et ebből fejlesztettem le.



