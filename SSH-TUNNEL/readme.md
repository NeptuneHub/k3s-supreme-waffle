# Introduction
In case you don't have an ISP with public IP for your home lab and you want to share service on the internet an SSH tunnel is a possibility.

In this guide we will look how to tunnel HTTP and HTTPS using a VM in cloud. 

So the main idea is that you have an inexpensive VM with a public ip on it and from then you redirect the request (the SSH tunnel) to your home lab.

# Public VM configuration
On the public VM you first need to configure SSH to enable port forwarding so:

```
sudo vim /etc/ssh/sshd_config
```

then add this two line:

```
AllowTcpForwarding yes
GatewayPorts yes
```

Restart SSH and is done
```
sudo systemctl restart ssh
```

# HomeLab configuration with crontab

First you need to install autossh

```
sudo apt update
sudo apt install autossh
```

then you need to edit the crontab to allow the tunnel to be up on each reboot, sop run this command:

```
crontab -e
```

and add this in the bootom:

```
@reboot autossh -M 0 -f -N -R 8443:localhost:443 your-username@vm-ip
@reboot autossh -M 0 -f -N -R 8080:localhost:80 your-username@vm-ip
```

**Important**: here you can put instead of localhost the Public IP of the service related to Traefik

If you want to enable it without the reboot you can just run this command:
```
autossh -M 0 -o "ServerAliveInterval 30" -o "ServerAliveCountMax 3" -f -N -R 443:localhost:443 your-username@vm-ip
autossh -M 0 -o "ServerAliveInterval 30" -o "ServerAliveCountMax 3" -f -N -R 80:localhost:80 your-username@vm-ip
```

# HomeLab configuration with service

I case the @reboot command in crontab doesn't work an alternative is configure a service that run at the startup.

First create the file service **autossh-tunnel.service**
```
sudo vim /etc/systemd/system/autossh-tunnel.service
```

with the following content

```
[Unit]
Description=AutoSSH Tunnel Service
After=network-online.target ssh.service

[Service]
Type=simple
ExecStart=/usr/local/bin/startup_script.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

then create the sh script **startup_script.sh**

```
sudo vim /usr/local/bin/startup_script.sh
```

with the following content 

```
#!/bin/bash

/usr/bin/autossh -M 0 -o "ServerAliveInterval 30" -o "ServerAliveCountMax 3" -f -N -R 443:192.168.3.11:443 root@vm-ip
/usr/bin/autossh -M 0 -o "ServerAliveInterval 30" -o "ServerAliveCountMax 3" -f -N -R 80:192.168.3.11:80 root@vm-ip
```

Now you just need to enable and start the service

```
sudo systemctl daemon-reload
sudo systemctl enable autossh-tunnel.service
sudo systemctl start autossh-tunnel.service
```

# CHECK
You can check if everything working on the public VM by looking at the open port with this command

```
root@ubuntu:~# sudo ss -tnlp | grep ':443'
```

It should show something like this for the port 443:
```
LISTEN 0      128          0.0.0.0:443       0.0.0.0:*    users:(("sshd",pid=885,fd=6))
LISTEN 0      128             [::]:443          [::]:*    users:(("sshd",pid=885,fd=7))
```

Also on the home lab VM you can run this command (setting the correct host):
```
autossh -M 0 -N -R 443:localhost:443 your-username@vm-ip
```

and look if it return error.
