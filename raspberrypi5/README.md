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

TBD

# Post-Install configuration
If at the beggining **the keyboard layout** is not configured correctly, after boot in the system you can reconfigure it by running this command:

```
sudo dpkg-reconfigure keyboard-configuration
```

If at the beggining **SSH connection** is not enable, jut check and then enabled it by 
```
systemctl status ssh
systemctl enable ssh
```

Setting the static ip is also needed for a server. So first at all we configured the DHCP of the router to assing the same as a default, but to be more secure we also configured it in ubuntu by adding this file
```
sudo vim /etc/netplan/99_config.yaml
```

then apply and check by

```
sudo chmod 600 /etc/netplan/99_config.yaml
sudo netplan apply
ip a
```

