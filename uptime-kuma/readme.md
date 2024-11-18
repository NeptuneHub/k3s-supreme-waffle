# Introduction
Uptime Kuma is an easy software to monitor the uptime of your homelab services. Is useful to commit it on an  external server from your homelab (otherwise when the server is down, also the monitor app is down). So in my case I committed it on Hetzner on a one node K3S installation.

# Install

In my use case I installed uptime-kuma on k3S on a VM that I already use for SSH tunnel (see more in /SSH-TUNNEL). Because 443 and 80 port was already used I installed K3S without traefik (that by defualt use this port and create issue):

```
curl -sfL https://get.k3s.io | sh -s - server --cluster-init --disable traefik
rm $HOME/.kube/config
mkdir -p $HOME/.kube
sudo cp -i /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo chown $(id -u):$(id -g) /etc/rancher/k3s/k3s.yaml
```

Then I deployed it using the deployment.yaml fiel where you just need to:
* In the SVC replace <your-server-ip> with your server ip => this is due to the fact that we didn't install traefik on K3S

Then just apply it
```
kubectl apply -f deployment.yaml
```

# References
* **Uptime Kuma Github** - https://github.com/louislam/uptime-kuma
