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

# Traefik Certificate Renewal troubleshooting
There is an issue in the renewal of certificate in traefik. Cert-Manager automatically create a new Ingress for the renewal in the same namespace of the ingress that use the certificate.
This ingress is called acme-something and use the deprectated annotation to set the ingress class to traefik, intestat the spec.ingressClassName.

The solutions is find the acme ingress automatically created and add this annotations:
```
annotations:
    cert-manager.io/cluster-issuer: my-issuer
    acme.cert-manager.io/http01-edit-in-place: "true"
```

and this spec:
```
spec:
    ingressClassName: my-traefik-controller
```

**References**
* **Cert Manager Documentation** - https://cert-manager.io/v1.6-docs/installation/helm/
* **Traefik Certificate Renewal troubleshooting** - https://stackoverflow.com/questions/71858067/skipping-service-no-endpoints-found-when-attempting-to-fetch-certificate-with
* **Traefik Certificate Renewal troubleshooting** - https://github.com/cert-manager/cert-manager/issues/5862
