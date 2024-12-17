# Introduction
here we are configuring the NFS Server and then mount it on the client side in different way (directly on the host system or mounting it as StorageClass on K3S).
We are configuring the NFS server on the ip 192.168.3.134, if you have a different ip just change it accordingly.

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

# Mount it with a storage class

To mount it as a storage class yoy need to run this command

```
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --namespace nfs --create-namespace --set nfs.server=192.168.3.134 --set nfs.path=/mnt/NFS1
```

Now you can create a PVC in this way:
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-pvc
  namespace: your-namespace
spec:
  storageClassName: nfs-client
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1000Mi
```


# References
* **NFS SUBDIR GITHUB** - https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner
* **Reddit references** - https://www.reddit.com/r/kubernetes/comments/1hfu73f/nfs_storage/
