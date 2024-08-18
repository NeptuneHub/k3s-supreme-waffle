# Introduction
Metallb is a software loadbalancer that come very useful when you have a multiple node cluster. In short instead to attach the DNS to the node ip (that in case of fail is unreachable) you can use the ip that Metallb automatically assign to the loadbalancer ip of traefik (that is un kube-system namespace for K3S).

#Installation
The inistial installation can be done with the helm chart:

```
helm repo add metallb https://metallb.github.io/metallb
helm show values metallb/metallb > values.yaml
helm install metallb metallb/metallb -f values.yaml --namespace metallb-system --create-namespace
```

then is importat that you assign the privilage to the metallb namespace:
```
# Apply 'enforce' label
kubectl label namespace metallb-system pod-security.kubernetes.io/enforce=privileged

# Apply 'audit' label
kubectl label namespace metallb-system pod-security.kubernetes.io/audit=privileged

# Apply 'warn' label
kubectl label namespace metallb-system pod-security.kubernetes.io/warn=privileged
```

The last step is deploy the configuration, you can use for example config.yaml in this repo but remember to change the **addresses**. Is important to use addresses in your newtork (in this case LAN) that are not used by the DHCP of your router.

Then apply:

```
kubectl apply -f config.yaml
```

From now you will see that every service of type loadbalancer will automatically have assigned an external-ip from metallb.
