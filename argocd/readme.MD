# Introduction
ArgoCD can be installed for continuos delivery, this means that you can put the manifest on an external repository (like github) and having ArgoCD that sync from git and automatically deploy the manifest on your cluster. **This is particularry important in case you need to restore your application** (for exmaple for Disaster Recovery).

In this page we will explain how to install it on K3S.

# Install
Installation can be don with this command:

```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

then you also need to install the cli on your host:

```
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
```

# Ingress configuration
First you need to apply the **configmap.yaml** in this repo:

```
kubectl apply -f configmap.yaml
```

This because by default argocd wan't to be the endpoint of TLS, instead on K3S we want to use traefik.

Then you can deploy the **ingress.yaml** (before remember to edit it and inser the right endpoint of your server)

```
kubectl apply -f ingress.yaml
```


