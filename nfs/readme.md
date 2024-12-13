# Introduction
In this guide we suppose to have 3 node (ubuntu2, ubuntu3 and ubuntu4) and to install NFS server on each of them. Then each one can mount the shared folder of the other.
In our configuration all the machine are on the network 192.168.3.0/24 ad are .131 .132 and .133 so in apply the configuration change it accordingly to your network

# 1 - Install and configure NFS SERVER on each nodes
On all three nodes (ubuntu2, ubuntu3, and ubuntu4), install both the NFS server and client packages:

```
sudo apt update
sudo apt install nfs-kernel-server nfs-common
sudo systemctl enable nfs-kernel-server
sudo systemctl start nfs-kernel-server

```

Create the directory to share. Each server will share a directory:
```
ubuntu2 will share /srv/nfs/ubuntu2
ubuntu3 will share /srv/nfs/ubuntu3
ubuntu4 will share /srv/nfs/ubuntu4
```

On all three nodes, create the directories to be shared:

On ubuntu2:
```
sudo mkdir -p /srv/nfs/ubuntu2
```

On ubuntu3:
```
sudo mkdir -p /srv/nfs/ubuntu3
```

On ubuntu4:
```
sudo mkdir -p /srv/nfs/ubuntu4
```

Now you need to set Permissions on Shared Directories. You applied chmod 777 to give full read/write/execute permissions to all users. Run this command on all shared directories:

ubuntu2
```
sudo chmod 777 /srv/nfs/ubuntu2
```

ubuntu3
```
sudo chmod 777 /srv/nfs/ubuntu3
```

ubuntu4
```
sudo chmod 777 /srv/nfs/ubuntu4
```
Now you need to Configure /etc/exports for NFS Shares. Edit the /etc/exports file on each server to specify which clients can access the shared directories.

On ubuntu2, edit /etc/exports:
```
sudo vim /etc/exports
```

Add the following line:
```
/srv/nfs/ubuntu2 192.168.3.0/24(rw,sync,no_subtree_check)
```

On ubuntu3, edit /etc/exports:
```
sudo vim /etc/exports
```

Add the following line:
```
/srv/nfs/ubuntu3 192.168.3.0/24(rw,sync,no_subtree_check)
```

On ubuntu4, edit /etc/exports:
```
sudo vim /etc/exports
```

Add the following line:
```
/srv/nfs/ubuntu4 192.168.3.0/24(rw,sync,no_subtree_check)
```

After editing the /etc/exports file, apply the changes by re-exporting the shares:

```
sudo exportfs -r
```

Now you need to restart the NFS service to ensure it is active:

```
sudo systemctl restart nfs-kernel-server
```

# 2- Mount NFS folder as a CLIENT
On each client (ubuntu2, ubuntu3, ubuntu4), create the mount points where the NFS shares will be mounted.

On ubuntu2:

```
sudo mkdir -p /mnt/ubuntu3
sudo mkdir -p /mnt/ubuntu4
```

On ubuntu3:
```
sudo mkdir -p /mnt/ubuntu2
sudo mkdir -p /mnt/ubuntu4
```

On ubuntu4:
```
sudo mkdir -p /mnt/ubuntu2
sudo mkdir -p /mnt/ubuntu3
```

To automatically mount the NFS shares at boot time, edit the /etc/fstab file on each node.

On ubuntu2, edit /etc/fstab:

```
sudo vim /etc/fstab
```

Add the following lines:

```
192.168.3.132:/srv/nfs/ubuntu3 /mnt/ubuntu3 nfs defaults 0 0
192.168.3.133:/srv/nfs/ubuntu4 /mnt/ubuntu4 nfs defaults 0 0
```

On ubuntu3, edit /etc/fstab:
```
sudo vim /etc/fstab
```

Add the following lines:
```
192.168.3.131:/srv/nfs/ubuntu2 /mnt/ubuntu2 nfs defaults 0 0
192.168.3.133:/srv/nfs/ubuntu4 /mnt/ubuntu4 nfs defaults 0 0
```

On ubuntu4, edit /etc/fstab:
```
sudo vim /etc/fstab
```

Add the following lines:
```
192.168.3.131:/srv/nfs/ubuntu2 /mnt/ubuntu2 nfs defaults 0 0
192.168.3.132:/srv/nfs/ubuntu3 /mnt/ubuntu3 nfs defaults 0 0
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
