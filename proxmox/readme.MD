# Introduction
This is to install Proxmox  (proxmox 8.x) on Raspberry PI 5 with NVME SSD updating the PI OS LITE 64 bit os based on Debian bookworm.

With this configuration you're able to run 1 VM with 3Core / 6 GB, leaving the other resources to the host system and avoiding overprovisioning.

This solution is good for Laboratory & Testing giving the ability of proxmox of easy run backup&recovery.

# Installation

First you need to flash your NVME disk (using an USB3 to NVME adapter) with Raspberry PI OS LITE 64 bit (the one based on bookworm).

During the installation remember to assign a static ip to the machine (if you have a DHCP on your home rooter, you can reserver the ip of the machine).

**IMPORTANT** - Proxmox work on ehternet, WIFI is not supported, so use the ethernet cable.

Now that you have finished the installation of the base system, SSH to the machine and run:
```
apt-get update
apt-get upgrade
apt-get install vim
```

Then edit host profile **vim /etc/hosts** with this value (in this case **hostname=proxmox1** and static ip is **192.168.3.119**)

```
127.0.0.1 localhost proxmox1
192.168.3.119 proxmox1
::1 localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

then reboot

No add a password to the user root (then you will use it to login on proxmox web interface)
```
sudo passwd root
```

Add source keys list and gpgp
```
curl -L https://mirrors.apqa.cn/proxmox/debian/pveport.gpg | sudo tee /usr/share/keyrings/pveport.gpg >/dev/null

echo "deb [deb=arm64 signed-by=/usr/share/keyrings/pveport.gpg] https://mirrors.apqa.cn/proxmox/debian/pve bookworm port" | sudo tee /etc/apt/sources.list.d/pveport.list
```


Then proceed with the installation:
```
apt-get update
apt-get upgrade
apt-get full-upgrade
apt-get dist-upgrade

sudo apt install ifupdown2 proxmox-ve postfix open-iscsi pve-edk2-firmware-aarch64
```

Installation complete, now you can access to the web interface with something like:
```
https://192.168.3.119:8006
```

using as a credential: 
```
user:root
password: what you confgiured initially
```

# Setting network bridge
To give external connectivity to your VM one possibility is setting a bridge. Go to proxmox1 > System > Network and you should have your ethernet cable named ad **eth0**, here you can click on create > Linux Bridge and insert something like:

```
name: vmbr0
IPV4/CIDR: 192.168.3.119/24 => this is IP and mask of your proxmox1 node
Gateway: 192.168.3.1 => this is the ip of your roter
Autostart: checked
Bridge ports: eht0 => this is your network interface name
```

**Important** before click on "apply configuration" be sure of this configuration, becuase otherwise you will lose the access to the machine from web insterface / ssh and you will need to connect directly to the machine with monitor and keyboard to solve it.

In case you need to solve it, connect with monitor and keyboard and edit the configuration file by this command
```
vi /etc/network/interfaces
```

you should put something like this:
```
auto lo
iface lo inet loopback
iface eth0 inet manual

auto vmbr0
iface vmbr0 inet static
address 192.168.3.119/24
gateway 192.168.3.1
bridge-prots eth0
bridge-stp off
bridge-fd 0

sources /etc/network/interfaces.d/*
```

After saving to apply the configuration you need to run this commnad:
```
service networking restart
```

# ADD ISO image
To create the VM you first need to add the iso image for the installation, you can go to proxmox1 > local > ISO image and you can chose to **upload** from your local machine or directly **download from url** 

# Create VM
Finally you can create the VM by going to proxmox1 > button create VM.

Here you can configure all the information like name of the machine, iso, CPU, RAM and so on.

Important is thati n System you select OVMF (UEFI) because you're on arm machine and you need to use ARM iso.

Is also important that in network you select the bridge connection that you created so vmbr0

# References
* **Install proxmox on raspberry pi** - https://gist.github.com/enjikaka/52d62c9c5462748dbe35abe3c7e37f9a
* **Install proxmox on raspberry pi** - https://www.html.it/articoli/proxmox-virtualizzazione-su-raspberry-pi/
