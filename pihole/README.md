# Pihole configuration on K3S with mojo helm chart
This guide is to commit PIHOLE on K3S. This product is born as network blocker but it's also useful to be used as an home-lab DNS.

First thinks you need to configure cert-manager by following the instruction in ./cert-manager. We will use it with the self signed certificate because here our plan is to **commmit it visible only inside our home lab LAN**.

After that you need to add the repository in helm

```
helm repo add mojo2600 https://mojo2600.github.io/pihole-kubernetes/
helm repo update
```

creating the namespace:
```
kubectl create namespace pihole
```
You can use the **values.yaml** in this repository remembering to edit:
* The password of the admin console
* The ip of your machine
* The customDnsEntries where for the moment I place only one example

and by te end you can run the installation:
```
helm install pihole mojo2600/pihole --namespace pihole -f values.yaml
```
Now you need to create the ingress for the admin web-page, you can use the **ingress-tls.yaml** example in this repository just remembering ot change "192.168.3.120" with the local ip to you machine and apply it:

```
kubectl apply -f ingress-tls.yaml
```

With this you should to be able to access to the admin page with an address similar to this:
```
https://pihole.192.168.3.120.nip.io/admin
```

To finish the work you also need to expose on external ip the service for the dns and the dhcp, you can use a command like this just putting in your machine ip:
```
kubectl patch svc pihole-dns-tcp -n pihole -p '{"spec":{"externalIPs":["192.168.3.120"]}}'
kubectl patch svc pihole-dns-udp -n pihole -p '{"spec":{"externalIPs":["192.168.3.120"]}}'
kubectl patch svc pihole-dhcp -n pihole -p '{"spec":{"externalIPs":["192.168.3.120"]}}'
```

# Pihole configuration on K3S with yaml file
If you want to do a more detailed configuration you can use the deployment.yaml file in this repo and just edit it.

It contain deployment, service, ingress and also the secret with the admin password. So you need to configure:
* The ip of your machine where you find it (so in place of 192.168.3.120)
* The name of the ingress putting also the ip of your machine (where you have http://pihole.192.168.3.120.nip.io/)
* You webpassword, that is the admin password to login

After editing it with your personal information, apply with the command:
```
kubectl apply -f deployment.yaml
```


# DNS on Router and K3S
After installing and configuring pihole you need to enter in your router and assign to the primary DNS the ip address of your PIHOLE (in our cases is 192.168.3.120). A good idea is also to assign as a secondary DNS the one of google (like 8.8.8.8) so in case of Pihole go down you will automatically switch to google once.

On the server where K3S work is also important to check the DNS configuration. On Ubuntu 24.04, despite the router configuration, I got the problem that it got pihole as the only DNS server. The result was that when you re-deploy pihole (for whatever reason) you stay without DNS. To avoid this is better if the K3S server where you have Pihole don't use it.

On ubuntu you use **systemd-networkd** by default so:
```
cd /etc/systemd/network
vim 10-wlan0.network
```

and put
```
[Match]
Name=wlan0  # Replace with your actual wireless interface name

[Network]
DNS=8.8.8.8 8.8.4.4
```

and then:
```
sudo systemctl restart systemd-networkd
resolvectl status
```

if you still got problem when Pihole is down in DNS resolution (you can test if ping google.it work for example) try also this step:
```
sudo systemctl stop systemd-resolved 
sudo rm /etc/resolv.conf 
echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" | sudo tee /etc/resolv.conf
sudo systemctl restart systemd-networkd
sudo systemctl start systemd-resolved 
```

#Update
Before an update be sure to backup all the configuration. Then you can run this command to force K3S to remove the actual image and force a redeployment of the pod with the new one:
```
sudo crictl rmi pihole/pihole:latest
kubectl rollout restart deployment -n pihole
```

If the password for login is re-setted you can set a new one (like a blank one) with a command like this (remember to put correct namespace and pod name):
```
kubectl exec -it -n pihole pihole-d5c85f7c7-xkl5b -- pihole setpassword ''
```


**References**
* **Pihole Kubernetes github repo** - https://github.com/MoJo2600/pihole-kubernetes
* **Pihole configuration**- https://greg.jeanmart.me/2020/04/13/self-host-pi-hole-on-kubernetes-and-block-ad/

