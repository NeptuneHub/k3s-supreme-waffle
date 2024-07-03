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

**References**
* **Pihole Kubernetes github repo** - https://github.com/MoJo2600/pihole-kubernetes
* **Pihole configuration**- https://greg.jeanmart.me/2020/04/13/self-host-pi-hole-on-kubernetes-and-block-ad/

