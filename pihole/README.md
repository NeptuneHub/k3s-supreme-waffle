This guide is to commit PIHOLE on K3S. This product is born as network blocker but it's also useful to be used as an home-lab DNS.

First thinks you need to configure cert-manager by following the instruction in ./cert-manager. We will use it with the self signed certificate.

After that you need to add the repository in helm

```
helm repo add mojo2600 https://mojo2600.github.io/pihole-kubernetes/
helm repo update
```

creating the namespace:
```
kubectl create namespace pihole
```

and by te end you can run the installation using the values.yaml in this repository:
```
helm install pihole mojo2600/pihole --namespace pihole -f values.yaml
```
