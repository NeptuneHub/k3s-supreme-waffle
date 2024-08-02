# Introduction
In this page I'll collect the result of my test on a Raspberry Pi 0 2W that work with an internal SD card

# K3S Agent
My first attemp is to install K3S as an agent, due to the small ram (K3S require at least 1GB). You can do by using this command:

```
curl -sfL https://get.k3s.io | K3S_URL=https://<your-master-node-ip>:6443 K3S_TOKEN=<your_token> sh -i
```

If you have error in installation, remember to check the open port on the main server. You can get more information in the ./hardening section of this repo.

# Pihole on K3S agent
Deploying Pihole on K3S agent that n on Raspberry Pi 0 2w is totally possible with the 512 mb for an home using.

To say to K3S on which node to deploy pihole, we assing this lable to our 2-node cluster (where ubunut1 is the master and ubuntu2 is the PI 0 2w):

```
kubectl label nodes ubuntu1 app=high --overwrite 
kubectl label nodes ubuntu2 app=low --overwrite
```
You can also check the result wuith:

```
kubectl get nodes --show-labels
```

Then you can deploy pihole using the label "app=low", before using the deployment in this repo remember to set this value:
*  WEBPASSWORD - put the base64 of your admin user password
* externalIPs: - 192.168.3.120 - put your machine ip, this will be the ip of your DNS
* host: pihole.192.168.3.120.nip.io  - put your machine ip here, this will be the url of the web admin dashboard

then you can apply it with:
```
kubectl apply -f deployment.yaml
```

# SAMBA
Here we will configure samba directly on the host system, not using K3S. By my test it worked very well, I connected to it with my Android phone, starting to looking at photo preview and RAM still remain on a max of 300mb, with also no much CPU usage.
As a storage I used the internal SD card and I used the integrated wifi.


First install samba on the machine:
```
sudo apt update 
sudo apt upgrade
sudo apt install samba
```

Then we will add an user for samba called samba:
```
sudo adduser samba
```

Then switch to samba user and create the dir that you want to share:
```
su samba
mkdir -p ~/shared
sudo chmod 777 ~/shared
exit
```

BACK ON your normal SUDO user:

```
sudo smbpasswd samba
```

Now you need to edit the configuration of samba by run this command:
```
sudo vim  /etc/samba/smb.conf
```

And add this line to share your folder:

```
[Shared]
path = /home/samba/shared
browseable = yes
read only = no
guest ok = no
```

Finally you only need to run this command to restart samba and get the new configuration:
```
sudo systemctl restart smbd 
sudo systemctl restart nmbd 
```

Then if you want to mount this shared folder on another linux machine (I used ubuntu) run this comand to install the depedencies:


```
sudo apt update
sudo apt install cifs-utils
```

Create the folder where you will mount you shared folder:
```
sudo mkdir -p /mnt/ubuntu2-shared
```

Put the creential of you samba user here:
```
sudo vim /etc/samba/credentials
```

in this format:
```
username=samba
password=examplepassword
```

and give the correct permission:
```
sudo chmod 600 /etc/samba/credentials
```

Now to mount it at every restart edit the fstab with this command:
```
sudo vim /etc/fstab
```

and add this line on the bottom (rembemer to change 192.168.3.130 with the IP of your samba server):
```
//192.168.3.130/Shared /mnt/ubuntu2-shared cifs credentials=/etc/samba/credentials,uid=1000,gid=1000,iocharset=utf8 0 0
```

Finally run this command:
```
sudo systemctl daemon-reload
sudo mount -a
```

and the configuration is completed.


