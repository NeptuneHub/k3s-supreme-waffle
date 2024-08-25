# UNDER CONSTRUCTION

# Install postgresql in HA with zalando

To install postgresql in HA you can usew the beloww configuration. Befroe applying it you just need to remeber to edit the file **users.yaml** in order to set the base64 password

```
kubectl create namespace authentik-ha
helm repo add postgres-operator-charts https://opensource.zalando.com/postgres-operator/charts/postgres-operator
helm install postgres-operator postgres-operator-charts/postgres-operator --namespace zalando-op --create-namespace --values zalando-op-values.yaml
```

```
helm repo add postgres-operator-ui-charts https://opensource.zalando.com/postgres-operator/charts/postgres-operator-ui
helm install postgres-operator-ui postgres-operator-ui-charts/postgres-operator-ui --namespace zalando-op --create-namespace
kubectl apply -f zalando-deplyment.yaml
```

# Install redis in HA

**This part is still under construction becase I'm checking if Authentik work with redis with sentinel or redis-cluster**
```
helm upgrade --install redis oci://registry-1.docker.io/bitnamicharts/redis-cluster -f values.yaml  --namespace authentik-ha
helm upgrade --install redis oci://registry-1.docker.io/bitnamicharts/redis -f values-standard.yaml  --namespace authentik-ha
```

# Install Authentik in HA

**This part is still under construction, will be updated depending of the redis installatuion**

To install Authentik in ha the main part that change are the **auth-values.yaml** the other are similar to the "not ha" configuration. Remember to edit the values to edit your password.
```
helm upgrade --install authentik authentik/authentik -f auth-values.yaml --namespace authentik-ha
kubectl apply -f ingress.yaml
kubectl apply -f middleware.yaml
kubectl apply -f service-ingress-route.yaml
```
