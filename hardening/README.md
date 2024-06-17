Because by the end K3S work on top of an O.S we had to make some basic hardening to improve the security of the system.
This was made based on Ubuntu 24.04 but most of them will probably works even for other Linux O.S.

**disclaimer** Also remember that this is only some suggestions that I used on my own, they could be not sufficient. So make your research.

# SSH

First make some SSH hardening, so start to edit the sshd_config but first note:

* **Important** here we are changing the SSH port from 22 to 2222 to avoid some basic automated attack. This means that in the next login you should specify the -p 2222 in your SSH command;
* **Important2** here we are disabling the access by password, before that I suggest to configure you SSH key to access to the server;
* **Important3** we are enabling the access by ssh only from root user. If it's not your case comments the string.

```
sudo vim /etc/ssh/sshd_config.d/99-custom.conf
```

and be sure that this are present and not commented:
```
# Passwords are depricated in favor of SSH keypair authentication
PasswordAuthentication no
PermitEmptyPasswords no
PermitUserEnvironment no 
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
sudo ufw limit 2222/tcp  
sudo ufw enable
sudo ufw default deny incoming 
sudo ufw default deny forward 
sudo ufw limit 80/tcp 
sudo ufw limit 443/tcp 
```

this configuration is for only one node. Using of limit instead of allow help to prevent ddos attack. 

If you have multiple node you shoud also open this port:

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


# Ubuntu security update
This is for update the system and enalbe the automatic security update:

```
apt update
apt -y upgrade
apt -y dist-upgrade
apt -y install unattended-upgrades
dpkg-reconfigure unattended-upgrades
shutdown -r now
```

To enalbed the unattend update at 2:00 at night edit this file:
```
sudo vim /etc/apt/apt.conf.d/50unattended-upgrades
```

and check that the unattended update are uncommented:
```
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-WithUsers "true";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";
```

then apply the change
```
systemctl restart unattended-upgrades.service
systemctl status unattended-upgrades.service
```

# Fail2ban

This application is to ban failed attemp of login on the different systemn. For this you need to make a configuration file with the application in scope and a filter for each application. This because this applications works by pharsing the log file.


First install it

```
apt install fail2ban
```

Then create the custom configuration file

```
sudo vim /etc/fail2ban/jail.d/99-custom.conf
```

use this value but remember to put the exact loghpat of nextcloud.log (in mine for example I puth the path including the pvc dicretory)

```
[nextcloud]
backend = auto
enabled = true
port = 80,443
protocol = tcp
filter = nextcloud
maxretry = 3
bantime = 86400
findtime = 43200
logpath = /var/lib/rancher/k3s/storage/pvc-c7f870cc-06b6-4d27-af5f-c5489bb4c520_nextcloud_nextcloud-server-pvc/data/nextcloud.log

[sshd]
enabled = true
port    = 2222
filter  = sshd
logpath = /var/log/auth.log
maxretry = 5
findtime = 10m
bantime = 1h
```

then create the filter for nextcloud as described in nextcloud documentation:

```
vim /etc/fail2ban/filter.d/nextcloud.conf
```

and here the value
 ```
[Definition]
_groupsre = (?:(?:,?\s*"\w+":(?:"[^"]+"|\w+))*)
failregex = ^\{%(_groupsre)s,?\s*"remoteAddr":"<HOST>"%(_groupsre)s,?\s*"message":"Login failed:
            ^\{%(_groupsre)s,?\s*"remoteAddr":"<HOST>"%(_groupsre)s,?\s*"message":"Trusted domain error.
datepattern = ,?\s*"time"\s*:\s*"%%Y-%%m-%%d[T ]%%H:%%M:%%S(%%z)?"
```

For ssh the pharser already exist so you don't need to create.

Now to enable the log2ban and check the status

```
systemctl enable fail2ban.service
systemctl restart fail2ban.service
systemctl status fail2ban.service
```

#Aide
Aide create a database of checksum of all the file in the system (or you can exclude some). Then running additional scan you can check what is changed in the system.

To install it
```
sudo apt-get install aide
sudo aideinit 
```

wait several minutes (even 1 hours or more depeds from how many files did you have in the system) for finishing it.

Now you need to move the new database created in this way


```
sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
```

after that you can try to create a file or change something in the system and then you can run

```
sudo aide --check --config=/etc/aide/aide.conf > check.log 2>&1
```


The main folder of aide on an ubuntu system are:
* /etc/aide - configuration file
* /var/lib/aide - database create after an init command or an update
* /var/log/aide/ - log

after a scheduled updatet you need to update the database by running this command:
```
sudo aide --update
```

You should also schedule the aide check by running this command:

```
sudo cronotab -e
```

and inser this line (remember to change root/aide with the folder which you want the output):

```
0 6 * * * /usr/sbin/aide --check --config=/etc/aide/aide.conf > /root/aide/aide_$(date +\%Y\%m\%d_\%H\%M\%S).txt 2>&1
```

**References:**
* **Ubuntu hardening for kubernetes and nextcloud** - https://www.blunix.com/blog/howto-install-nextcloud-on-ubuntu-2204-with-hetzner.html#selecting-and-renting-the-server-cloud
* **Fail2ban configuration for nextcloud** - https://docs.nextcloud.com/server/19/admin_manual/installation/harden_server.html?highlight=fail2ban#setup-a-filter-and-a-jail-for-nextcloud
* ** DISA STIgs for ubuntu** - https://public.cyber.mil/stigs/downloads/
* ** Openscap for ubuntu 20.04** - https://static.open-scap.org/ssg-guides/ssg-ubuntu2204-guide-index.html
