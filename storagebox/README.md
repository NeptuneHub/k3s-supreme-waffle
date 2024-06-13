This guide is useful to mount on linux an SSH folder in order to be used for persisten volume. This guide was executed using the **Storage Box offered by Hetzner**.

So first think you need to do is to create your SSH storage, if you use the Storage box by Hetzner remember to allow the SSH connetion from the control panel.

Fir step you need to install sshf and create an SSH key for this purpose

```
apt install sshfs
mkdir /root/.ssh
chmod 700 /root/.ssh
ssh-keygen -t ed25519 -a 100 -o -N '' -f /root/.ssh/id_ed25519_storage_box
```

Then you can proceed to install you SSH key and mount the folder for a first test. Only this time it will require your password

**Important** here you need yto change the connection string in the formay user@server. For storage box the important things is that you replace uXXXXX with your user

```
cat ~/.ssh/id_ed25519_storage_box.pub | ssh -p 23 uXXXXX@uXXXXX.your-storagebox.de install-ssh-key
sshfs -o IdentityFile=/root/.ssh/id_ed25519_storage_box -p 23  uXXXXX@uXXXXX.your-storagebox.de:/home /mnt
```

Now check that it is correctly mounted and then unmount it
```
df -ha /mnt
umount /mnt
```

Let's create a service that mount the SSH folder to each startup, you can get **var-www-nextcloud-nextcloud-data.mount** and put in this location:
```
/etc/systemd/system/
```

Now you can lunch the service and check the status of the service 
```
systemctl daemon-reload
systemctl enable var-www-nextcloud-nextcloud-data.mount
systemctl restart var-www-nextcloud-nextcloud-data.mount
systemctl status var-www-nextcloud-nextcloud-data.mount
```

and finally check the mounted store:
```
mount | grep nextcloud; ls -lha /var/www/nextcloud/nextcloud/data
```

Finally you can use it by usin for example PV and PVC in the example **pvc.yaml**

# Install Storagebox with Cfis

We look that with the above configuration we wasn't able to give the correct right to the folder. In this way when we tried to install nextcloud it doesnt work. For this reason we followd this other configuration.

Install the cifs-utils:
```
sudo apt-get install cifs-utils
```

Then add the connection line in the fstab, change uXXXXX with your username

```
vim /etc/fstab
//uXXXXX.your-storagebox.de/backup /mnt/backup-server cifs iocharset=utf8,rw,credentials=/etc/backup-credentials.txt,uid=0,gid=0,file_mode=0660,dir_mode=0770 0 0
```

Now create the file with the credentials:

```
vim /etc/backup-credentials.txt
```

it will be like this:
```
username=YOURUSARNAME
password=YOURPASSWORD
```

Now create the folder for the mount:

```
mkdir /mnt/backup-server
```

Restart the daemon and mount it:
```
systemctl daemon-reload
sudo mount -a
```

Now is completed.

In Ubunbut 24.04 we encountered error when we run the mount command that he didn't found cfis. For solve it we just installed this library and re-run the mount command:
```
sudo apt install linux-modules-extra-aws 
sudo apt install linux-modules-extra-azure
```


**References:**
* **Configuring storage box** - https://www.blunix.com/blog/howto-install-nextcloud-on-ubuntu-2204-with-hetzner.html#installing-nextcloud-from-source-files
* **hetzner Cfis documentation** - https://docs.hetzner.com/robot/storage-box/access/access-samba-cifs/
