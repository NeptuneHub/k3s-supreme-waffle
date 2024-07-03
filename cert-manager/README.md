This guide is to install cert-manager in K3S. This is usefull if you want to use TLS Certificate for example for nextcloud.

First you need to add to helm the repo and run the install command
```
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true 
```

# Lets Encrypt cluster issuer for Production
Now you need to create the ClusterIssuer, you can use cluster-issuer-production.yaml in this repo and apply it

```
kubectl apply -f cluster-issuer-production.yaml
```

Finally you can check it by this command:
```
kubectl get ClusterIssuer -A
```

# Self signed cluster issuer for Development
You can create a self-signed Cluster Issuer by applying self-signed-cluster-issuer.yaml in this repo:

```
kubectl apply -f self-signed-cluster-issuer.yaml
```

Finally you can check it by this command:
```
kubectl get ClusterIssuer -A
```


**References**
* **Cert Manager Documentation** - https://cert-manager.io/v1.6-docs/installation/helm/
