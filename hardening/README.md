Because by the end K3S work on top of an O.S we had to make some basic hardening to improve the security of the system.
This was made based on Ubuntu 24.04 but most of them will probably works even for other Linux O.S.

# SSH

First make some SSH hardening, so start to edit the sshd_config:

```
sudo vim /etc/ssh/sshd_config.d/99-custom.conf
```

and be sure that this are present and not commented:
```
# Passwords are depricated in favor of SSH keypair authentication
PasswordAuthentication no
PermitEmptyPasswords no
PubkeyAuthentication yes

# Change default SSH port to get rid of 99% of automated attacks
Port 2222

# We only login as root anyways (for convinience) so we might as well ban everyone else
AllowUsers root
AllowGroups root

# Disconnect after 5 minutes of idle to reduce risk of hijacking terminals
ClientAliveInterval 300
ClientAliveCountMax 0

# There are no xservers (graphical systems) on a nextcloud server
X11Forwarding no

# There are no xservers (graphical systems) on a nextcloud server
X11Forwarding no
```

Check if well formatted, you should have 0 as a result:
```
sshd -t; echo $?
```

If all is well formated then apply and check the status of the service
```
sudo systemctl restart ssh
sudo systemctl status ssh
```

# Firewall

For firewall we configured ufw by running this command:
```
sudo ufw allow 2222/tcp  
sudo ufw enable
sudo ufw default deny incoming 
sudo ufw default deny forward 
sudo ufw allow 80/tcp 
sudo ufw allow 443/tcp 
```

this configuration is for only one node. If you have multiple node you shoud also open this port:

```
# Allow traffic on TCP port 6443 (Kubernetes API server)
# Allow traffic on TCP ports 2379-2380 (etcd)
# Allow traffic on UDP port 8472 (VXLAN)
# Allow traffic on TCP port 10250 (Kubelet)
# Allow traffic on TCP ports 10251-10252 (Kubernetes control plane components)
# Allow traffic on TCP ports 30000-32767 (NodePort services)
```

My suggestions is to create a private network between the K3S note (for exampel a 192.168.1.0/24) and then

```
sudo ufw allow from 192.168.1.0/24 to any port 6443 proto tcp && \
sudo ufw allow from 192.168.1.0/24 to any port 2379:2380 proto tcp && \
sudo ufw allow from 192.168.1.0/24 to any port 8472 proto udp && \
sudo ufw allow from 192.168.1.0/24 to any port 10250 proto tcp && \
sudo ufw allow from 192.168.1.0/24 to any port 10251:10252 proto tcp && \
sudo ufw allow from 192.168.1.0/24 to any port 30000:32767 proto tcp
```

if you use longhorn on private network 192.168.1.0/24, you also need to open this:
```
sudo ufw allow from 192.168.1.0/24 to any port 80 proto tcp && \
sudo ufw allow from 192.168.1.0/24 to any port 443 proto tcp && \
sudo ufw allow from 192.168.1.0/24 to any port 3260 proto tcp && \
sudo ufw allow from 192.168.1.0/24 to any port 9500:9504 proto tcp && \
sudo ufw allow from 192.168.1.0/24 to any port 10250 proto tcp && \
sudo ufw allow from 192.168.1.0/24 to any port 10255 proto tcp && \
sudo ufw allow from 192.168.1.0/24 to any port 10256 proto tcp

```

If you are using  hetzner you can also configure their esternal firewall for free.
