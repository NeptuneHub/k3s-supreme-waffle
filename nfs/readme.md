# Introduction
In this guide we suppose to have 3 node (ubuntu2, ubuntu3 and ubuntu4) and to install NFS server on each of them. Then each one can mount the shared folder of the other.
In our configuration all the machine are on the network 192.168.3.0/24 ad are .131 .132 and .133 so in apply the configuration change it accordingly to your network

# 1 - Install and configure NFS SERVER on each nodes
First you need to install the NFS server on the server side
```
sudo apt update
sudo apt install nfs-kernel-server nfs-common
sudo systemctl enable nfs-kernel-server
sudo systemctl start nfs-kernel-server
```

Create the directory to share and give the permissions.
```
sudo mkdir -p /mnt/NFS1
sudo chmod 777  /mnt/NFS1
```
hmod 777  /mnt/NFS1
```

Now you need to Configure /etc/exports for NFS Shares:

```
sudo vim /etc/exports
```

Add the following line that will allow the acess from the entire subnet:
```
/mnt/NFS1 192.168.3.0/24(rw,sync,no_subtree_check,fsid=0,crossmnt)
```

After editing the /etc/exports file, apply the changes by re-exporting the shares:

```
sudo exportfs -r
```

Now you need to restart the NFS service to ensure it is active:

```
sudo systemctl restart nfs-kernel-server
```

# Direct mount the folder on the host client
Create the mount points where the NFS shares will be mounted:
```
sudo mkdir -p /mnt/NFS1
```
To automatically mount the NFS shares at boot time, edit the /etc/fstab:

```
sudo vim /etc/fstab
```

Add the following lines:

```
192.168.3.134:/srv/nfs/ubuntu3 /mnt/ubuntu3 nfs defaults 0 0
```

On ubuntu3, edit /etc/fstab:
```
sudo vim /etc/fstab
```

Add the following lines:
```
192.168.3.134:/mnt/NFS1 /mnt/NFS1 nfs rw,sync,hard,intr,timeo=600,retrans=2 0 0
```

After adding the entries in /etc/fstab, run the following command to mount all the NFS shares:
```
systemctl daemon-reload
sudo mount -a
```

You can verify that the NFS shares have been mounted correctly by running:
```
df -h
```
