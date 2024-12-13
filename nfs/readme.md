# Introduction
In this guide we suppose to have 3 node (ubuntu2, ubuntu3 and ubuntu4) and to install NFS server on each of them. Then each one can mount the shared folder of the other.

# Install and mount NFS

1. Setup on Each Node (ubuntu2, ubuntu3, ubuntu4)
1.1 Install NFS Server and Client
On all three nodes (ubuntu2, ubuntu3, and ubuntu4), install both the NFS server and client packages:

bash
Copia codice
sudo apt update
sudo apt install nfs-kernel-server nfs-common
2. Configure Shared Directories on All Servers
Each server will share a directory:

ubuntu2 will share /srv/nfs/ubuntu2
ubuntu3 will share /srv/nfs/ubuntu3
ubuntu4 will share /srv/nfs/ubuntu4
2.1 Create Shared Directories on Each Node
On all three nodes, create the directories to be shared:

On ubuntu2:
bash
Copia codice
sudo mkdir -p /srv/nfs/ubuntu2
On ubuntu3:
bash
Copia codice
sudo mkdir -p /srv/nfs/ubuntu3
On ubuntu4:
bash
Copia codice
sudo mkdir -p /srv/nfs/ubuntu4
2.2 Set Permissions on Shared Directories
You applied chmod 777 to give full read/write/execute permissions to all users. Run this command on all shared directories:

On all nodes (ubuntu2, ubuntu3, and ubuntu4):
bash
Copia codice
sudo chmod 777 /srv/nfs/ubuntu2
sudo chmod 777 /srv/nfs/ubuntu3
sudo chmod 777 /srv/nfs/ubuntu4
2.3 Configure /etc/exports for NFS Shares
Edit the /etc/exports file on each server to specify which clients can access the shared directories.

On ubuntu2, edit /etc/exports:

bash
Copia codice
sudo nano /etc/exports
Add the following line:

bash
Copia codice
/srv/nfs/ubuntu2 192.168.3.0/24(rw,sync,no_subtree_check)
On ubuntu3, edit /etc/exports:

bash
Copia codice
sudo nano /etc/exports
Add the following line:

bash
Copia codice
/srv/nfs/ubuntu3 192.168.3.0/24(rw,sync,no_subtree_check)
On ubuntu4, edit /etc/exports:

bash
Copia codice
sudo nano /etc/exports
Add the following line:

bash
Copia codice
/srv/nfs/ubuntu4 192.168.3.0/24(rw,sync,no_subtree_check)
2.4 Re-export NFS Shares
After editing the /etc/exports file, apply the changes by re-exporting the shares:

bash
Copia codice
sudo exportfs -r
2.5 Restart NFS Service
Restart the NFS service to ensure it is active:

bash
Copia codice
sudo systemctl restart nfs-kernel-server
3. Configure Clients to Mount Shared Directories
Each node will mount the directories shared by the other two nodes.

3.1 Create Mount Points on All Clients
On each client (ubuntu2, ubuntu3, ubuntu4), create the mount points where the NFS shares will be mounted.

On ubuntu2:

bash
Copia codice
sudo mkdir -p /mnt/ubuntu3
sudo mkdir -p /mnt/ubuntu4
On ubuntu3:

bash
Copia codice
sudo mkdir -p /mnt/ubuntu2
sudo mkdir -p /mnt/ubuntu4
On ubuntu4:

bash
Copia codice
sudo mkdir -p /mnt/ubuntu2
sudo mkdir -p /mnt/ubuntu3
3.2 Add Mount Entries in /etc/fstab
To automatically mount the NFS shares at boot time, edit the /etc/fstab file on each node.

On ubuntu2, edit /etc/fstab:

bash
Copia codice
sudo nano /etc/fstab
Add the following lines:

bash
Copia codice
192.168.3.132:/srv/nfs/ubuntu3 /mnt/ubuntu3 nfs defaults 0 0
192.168.3.133:/srv/nfs/ubuntu4 /mnt/ubuntu4 nfs defaults 0 0
On ubuntu3, edit /etc/fstab:

bash
Copia codice
sudo nano /etc/fstab
Add the following lines:

bash
Copia codice
192.168.3.131:/srv/nfs/ubuntu2 /mnt/ubuntu2 nfs defaults 0 0
192.168.3.133:/srv/nfs/ubuntu4 /mnt/ubuntu4 nfs defaults 0 0
On ubuntu4, edit /etc/fstab:

bash
Copia codice
sudo nano /etc/fstab
Add the following lines:

bash
Copia codice
192.168.3.131:/srv/nfs/ubuntu2 /mnt/ubuntu2 nfs defaults 0 0
192.168.3.132:/srv/nfs/ubuntu3 /mnt/ubuntu3 nfs defaults 0 0
3.3 Mount the NFS Shares
After adding the entries in /etc/fstab, run the following command to mount all the NFS shares:

bash
Copia codice
sudo mount -a
4. Verify the Mounts
You can verify that the NFS shares have been mounted correctly by running:

bash
Copia codice
df -h
This will show the mounted NFS shares under /mnt/ubuntu2, /mnt/ubuntu3, and /mnt/ubuntu4 on each node.

5. Firewall Configuration (Optional)
If ufw (Uncomplicated Firewall) is enabled, make sure the firewall allows NFS traffic from the 192.168.3.0/24 network.

On each node, run the following commands:
bash
Copia codice
sudo ufw allow from 192.168.3.0/24 to any port nfs
sudo ufw reload
Summary of Configuration
All three nodes (ubuntu2, ubuntu3, ubuntu4) are both NFS servers and clients.
Each server shares a directory:
ubuntu2 shares /srv/nfs/ubuntu2
ubuntu3 shares /srv/nfs/ubuntu3
ubuntu4 shares /srv/nfs/ubuntu4
All three nodes mount the shared directories from the other nodes at /mnt/ubuntu2, /mnt/ubuntu3, and /mnt/ubuntu4.
Permissions are set to 777 on all shared directories to allow full read/write/execute access for everyone.
NFS shares are automatically mounted at boot via /etc/fstab.
The firewall (if enabled) allows NFS traffic from the 192.168.3.0/24 network.
Now all three nodes should be able to share and mount directories over NFS with full access, and everything is set up to persist across reboots.
