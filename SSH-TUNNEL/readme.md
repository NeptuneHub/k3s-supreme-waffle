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

# HomeLab configuration

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
autossh -M 0 -f -N -R 443:localhost:443 your-username@vm-ip
autossh -M 0 -f -N -R 80:localhost:80 your-username@vm-ip
```
