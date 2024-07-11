# Introduction
In several part of this repo I give different suggestion for backup, here I want to bring all together.

The starting point is having this two mointing point on your /etc/fstab:

```
//uXXXXXXXXXX.your-storagebox.de/backup /mnt/backup-server cifs iocharset=utf8,rw,credentials=/etc/backup-credentials.txt,uid=1000,gid=1003,file_mode=0660,dir_mode=0770,x-systemd.requires=network-online.target,x-systemd.automount 0 0
#usb hdd (black)
UUID=7A4E56564E560B71 /mnt/usb ntfs-3g defaults 0 0
```

As you can see the first one is a Hetzner Storage box and it will be used for off-site backup. For configuring it please follow the guide here:
https://github.com/NeptuneHub/k3s-supreme-waffle/tree/main/storagebox
