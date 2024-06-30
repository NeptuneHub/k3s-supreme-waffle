This guide is how to configure one node K3S cluster on Raspberry PI starting from the flashing of the SO.

# Hardware
As hardaware we used 
* 1 x Raspberry Pi 5 8GB Quad-Core ARMA76 (64 Bits - 2,4 GHz) - We preferred the 8gb ram mem to have a bit more power;
* 1x 52PI m.2 NVME SSD Adapter N040 for RPI 5 - This is the hat to connect the NVME ssd on Raspberry PI 5;
* 1x Patriot P300 M.2 2280 PCIe gen 3x4 NVMe SSD 1TB  - This is the 1TB NVME SSD, because we want to run Nextcloud and have enough space;
* 1x official active cooler;
* 1x Geeekpi metal case
* 1x 27 USBC power adapter

This configuration in Italy, on June 2024 costed around 270€

As optional we also had an external 1TB usb to have it as external backup.

# OS
As final OS we want to install Ubuntu Server 24.04 for ARM on the SSD from here: 
https://ubuntu.com/download/raspberry-pi

The downloaded file should be like this:
```
ubuntu-24.04-preinstalled-server-arm64+raspi.img.xz
```

We also keep Raspberry PI OS on the SD card for the initial installetion (also useful for future maintenance if any problem on SSD occur)

# Install Configuration
In short youn need to use Raspberry PI Imager to flash the OS from another computer, you can find it here
```
https://www.raspberrypi.com/software/
```

The goals is to configure the arget OS (Ubuntu) on the NVME SSD, what we did is:
* Flash an SD card with the Raspberry PI OS using the tools => this becasue by default the boot is from SD card;
* Start the system with the SD and then roon another time the Imager directly on the raspberry to flash the SSD with Ubuntu AND to set SSD as a primary boot device.

To set the SSD as a primary boot device, on a Raspberry PI OS terminal, first update the software

```
sudo rpi-eeprom-update
sudo rpi-eeprom-update -a
```

After that update the configuration by running this file
```
sudo -E rpi-eeprom-config --edit
```

you need to add this
```
PCIE_PROBE=1
BOOT_ORDER=0xf416
```
The boot order basically pass from 461 (USB-SDCARD-SSD) by default to 416 (USB-SSD-SDCARD) in order to boot first from the NVME and then from the SD card

After flashing the SSD and edit this config you just need to restart to boot from the NVME.


# Post-Install configuration - Keyboard layout fix
If at the beggining **the keyboard layout** is not configured correctly, after boot in the system you can reconfigure it by running this command:

```
sudo dpkg-reconfigure keyboard-configuration
```

# Post-Install configuration - SSH connection
If at the beggining **SSH connection** is not enable, jut check and then enabled it by 
```
systemctl status ssh
systemctl enable ssh
```

Also add your ssh public key on the raspberry by
```
 vim /home/guido/.ssh/authorized_keys
```

and just paster yours ssh key. If you don't have an SSH key on your client (not on raspberry server) just generate one by:
```
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```


# Post-Install configuration - Static ip
[THIS STATIC IP CONFIGURATION IS UNDER REVIEW. PELASE SKIP FOR NOW]

Setting the static ip is also needed for a server. So first at all we configured the DHCP of the router to assing the same as a default, but to be more secure we also configured it in ubuntu by adding this file (you can find an exmaple on this repo):
```
sudo vim /etc/netplan/99_config.yaml
```

then apply and check by

```
sudo chmod 600 /etc/netplan/99_config.yaml
sudo netplan apply
ip a
```

# Ubuntu and K3S configuration
The following guide was also applied and tested on raspberry pi with the following comments:
* /hardening - just remember to check in the SSH configuration the correct user that you use, with the normal ubuntu installation you create a new user instead of root
* /prometheus-stack - worked fine
* /imaginary - **this doesn't work** because  h2non/imaginary repo doesn't support ARM, to support arm you need to use as containers image nextcloud/aio-imaginary  (look ad imaginary-deployment-arm.yaml in this repo)
* /nextcloud - this worked fine. The only difference that I saw is that the starting time of a container on Raspberry (SSD) was around 4 minutes (so like the double that on a cloud server with 4vcpu and 8gb ram)

# Backup on external usb drive
Because here we are on site, I added a backup of the image of nextcloud on an external USB disk.
Edit your crontab
```
sudo crontab -e
```

and add this line for make a backup every hours
```
#backup on usb every hours at 20min
25 * * * * /home/guido/bootstrap/5-backup/backup.sh >> /home/guido/bootstrap/5-backup/backup.log 2>&1
```

remember to mount your usb disk by
```
sudo vim /etc/fstab
```

add this line editing the UUID of your HD (you can get the UUID with the command **sudo blkid**)
```
UUID=7A4E56564E560B71 /mnt/usb ntfs-3g defaults 0 0
```


As backup sh script you can use your own or try to edit my **backup.sh** where you need to edit:

* /mnt/usb should be your usb external hd
* The script work supposing that nextcloud use a pvc on a local path and the file stored per user are in a path like this **/var/lib/rancher/k3s/storage/pvc-7bcfa367-27ab-4ec3-8437-04aaf2b7131e_nextcloud_nextcloud-server-pvc/data/USERNAME/files**
* line 31 and 32: instead of admin you ned to put your nextcloud uername, you can also duplicate this line for multiple user

if you have a different configuration you will need to adapt this script.

I also added an extra backup on a Storagebox on Hetzner. You can adapt the same script by mounting the storagebox in the fstab in this way (remember to correct the url and create the backup-credentials.txt files):
```
//uXXXXXXXXXX.your-storagebox.de/backup /mnt/backup-server cifs iocharset=utf8,rw,credentials=/etc/backup-credentials.txt,uid=1000,gid=1003,file_mode=0660,dir_mode=0770,x-systemd.requires=network-online.target,x-systemd.automount 0 0
```
(more information in /storagebox)


**References**
* **Raspberry PI official documentation** - https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#raspberry-pi-bootloader-configuration
* **K3S configuration on Raspberry** - https://medium.com/@stevenhoang/step-by-step-guide-installing-k3s-on-a-raspberry-pi-4-cluster-8c12243800b9
* **Install ubuntu on Raspberry overview** - https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi#1-overview
* **Ubuntu Server ARM for Raspberry** - https://cdimage.ubuntu.com/releases/24.04/release/
