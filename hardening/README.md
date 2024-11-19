This hardening help to improve the security of the system, both Ubuntu and K3S.
This was made based on Ubuntu 24.04 but most of them will probably works even for other Linux O.S.

**disclaimer** Also remember that this is only some suggestions that I used on my own, they could be not sufficient. So make your research.

**Index:**
* [SSH](#SSH)
* [SSH-openSUSE](#SSH-openSUSE)
* [Firewall](#Firewall)
* [Ubuntu unattended update](#Ubuntu-unattended-update)
*  [openSuse Automatic Update](#openSUSE-automatic-update)
* [Fail2ban](#Fail2ban)
* [Aide](#Aide)
* [K3S-automated-update](#K3S-automated-update)
* [K3S-quota-limits](#K3S-quota-limit)
* [K3S-Network-Policy](#K3S-Network-Policy)
* [Suspend-policy](#Suspend-policy)

## SSH

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
AllowUsers root guido
AllowGroups root guido

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

## SSH-openSUSE

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
AllowUsers root guido
AllowGroups root users

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
sudo systemctl restart sshd
sudo systemctl status sshd
```


## Firewall

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


## Ubuntu-unattended-update
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
Unattended-Upgrade::OnlyOnAC "false";
```

then apply the change
```
systemctl restart unattended-upgrades.service
systemctl status unattended-upgrades.service
```

Because is a server you can also disable the battery status check (sometimes it block the unattended even if you're not using any battery):
```
sudo systemctl stop upower
sudo systemctl disable upower
```

You can check that it work by run:
```
sudo unattended-upgrades -d
```

Because I look multiple reboot for multiple kind of upgrade, I also disable the **apt-daily.timer** and **apt-daily-upgrade.timer** by running this command:

```
sudo systemctl disable apt-daily.timer
sudo systemctl disable apt-daily-upgrade.timer
sudo systemctl stop apt-daily.timer
sudo systemctl stop apt-daily-upgrade.timer
sudo systemctl stop ua-timer.service
sudo systemctl disable ua-timer.service
sudo systemctl stop ua-timer.timer
sudo systemctl disable ua-timer.timer
```



## openSUSE-automatic-update
This is the equivalent of unatthend update of ubuntu. So first install it:

```
sudo zypper refresh
sudo zypper update -y
sudo zypper dist-upgrade -y
sudo zypper install -y zypper-automatic
sudo systemctl enable --now zypper-automatic.timer
shutdown -r now
```

then edit the configuration
```
sudo vim /etc/zypp/automatic.conf
```

and add
```
AUTOMATIC_UPDATE="yes"
```

## Fail2ban

This application is to ban failed attemp of login on the different systemn. For this you need to make a configuration file with the application in scope and a filter for each application. This because this applications works by pharsing the log file.


First install it

```
apt install fail2ban
```

Then create the custom configuration file

```
sudo vim /etc/fail2ban/jail.d/99-custom.conf
```

use this value if you have, in addition to SSH, also nextcloud and grafana (otherwise add/remove the service):

```
[nextcloud]
backend = auto
enabled = true
port = 80,443
protocol = tcp
filter = nextcloud
maxretry = 5
bantime = 600
findtime = 43200
logpath = /var/log/pods/nextcloud_nextcloud-*/nextcloud/*.log

[sshd]
enabled = true
port    = 2222
filter  = sshd
logpath = /var/log/auth.log
maxretry = 5
findtime = 10m
bantime = 600

[grafana]
enabled = true
port = 80, 443
filter = grafana
logpath = /var/log/pods/dash_kube-prometheus-stack-grafana-*/grafana-sc-dashboard/*.log
maxretry = 5
bantime = 600
```

ssh and grafana filter already come with log2ban, instead for nextcloud you need to create the filter as described in nextcloud documentation:

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

## Aide
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
sudo crontab -e root
```

and inser this line (remember to change root/aide with the folder which you want the output):

```
0 6 * * * /usr/bin/aide --check --config=/etc/aide/aide.conf > /root/aide/aide_$(date +\%Y\%m\%d_\%H\%M\%S).txt 2>&1
```

## K3S-automated-update

This is to enable the automated update of K3S to the last stable release version.

First start installing it

```
kubectl create namespace system-upgrade
kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/latest/download/system-upgrade-controller.yaml
kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/latest/download/crd.yaml
```


Now you need to apply the plan
```
kubectl apply -f k3s-update-plan.yaml
```

Also remember to apply the label to the node that you want to update, for example for the node called ubuntu1 thas is a server:

```
kubectl label node ubuntu1 k3s-upgrade=server
```

You you can use the attached example. This file practicall desribe the plan for the update.

## K3S-quota-limit
Define resource quota (for the entire namespace) and limits (for the single deployment) could be a way to avodi that a single pod just keep all the resource and freeze the server.
In this reposiotry you can fine **resource-quota.yam**l that based on my home lab use define request and quota of CPU and RAM for pihole, nextcloud, cert-manager, prometheus-stack (dash) and immaginary. Feel free to edit them and apply with the command

```
kubectl apply -f resource-quota.yaml
```

## K3S-Network-Policy
K3S directly work on IPTABLES configuration, this means that you can have incosisntence on the configuration that you apply on UFW firewall. In other word on UFW you close one port, but then on K3S you run the risk to re-open it.
So to have the K3S network under controll is good to deploy NetworkPolicy that are policy that you can apply for each specific namespace in order to limit the traffic.

In this repo you can find **network-policy.yaml** that in essence limit expose only the prometheus stack dashboard (namespace dash) and nextcloud on 443. Imaginary is also configured to be reached only from Nextcloud namespace. I suggest to review them to check if they can apply to your specific use case.

To apply it you need to run this command:
```
# Label the namespace, needed for imaginary ad hoc comunication with nextcloud
kubectl label namespace nextcloud name=nextcloud --overwrite
kubectl apply -f network-policy.yaml
```

## Suspend-policy

This configuration is to avoid unwanted suspension on your server.
So edit this file:
```
sudo vim /etc/systemd/logind.conf
```

and remove the commnet from this line
```
HandleLidSwitch=ignore
HandleLidSwitchDocked=ignore
HandleSuspendKey=ignore
HandleHibernateKey=ignore
HandlePowerKey=ignore
IdleAction=ignore
```

then apply this change by

```
sudo systemctl restart systemd-logind
```

You can also avoid that other process call the service for suspend or ibernate by masking the service with this command:
```
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```


**References:**
* **Ubuntu hardening for kubernetes and nextcloud** - https://www.blunix.com/blog/howto-install-nextcloud-on-ubuntu-2204-with-hetzner.html#selecting-and-renting-the-server-cloud
* **Fail2ban configuration for nextcloud** - https://docs.nextcloud.com/server/19/admin_manual/installation/harden_server.html?highlight=fail2ban#setup-a-filter-and-a-jail-for-nextcloud
* **DISA STIgs for ubuntu** - https://public.cyber.mil/stigs/downloads/
* **Openscap for ubuntu 20.04** - https://static.open-scap.org/ssg-guides/ssg-ubuntu2204-guide-index.html
* **K3S automated upate** - https://docs.k3s.io/upgrades/automated
* **K3S update plan** - https://github.com/rancher/system-upgrade-controller/blob/master/examples/k3s-upgrade.yaml
* **K3S Hardening** - https://docs.k3s.io/security/hardening-guide
* **openSuse upgrade** - https://github.com/losuler/zypper-automatic
