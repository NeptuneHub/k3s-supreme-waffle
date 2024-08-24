# UNDER CONSTRUCTION

# Install postgresql in HA with cloudnative-pg
```
kubectl create namespace authentik-ha
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --install cnpg --namespace cnpg-system --create-namespace cnpg/cloudnative-pg
kubectl apply -f users.yaml
helm upgrade --install database --namespace authentik-ha --create-namespace --values values.yaml cnpg/cluster
```

# Install redis in HA

CHECK if work redis with sentinel or redis-cluster
```
helm upgrade --install redis oci://registry-1.docker.io/bitnamicharts/redis-cluster -f values.yaml  --namespace authentik-ha
helm upgrade --install redis oci://registry-1.docker.io/bitnamicharts/redis -f values-standard.yaml  --namespace authentik-ha
```

# Install Authentik in HA
helm upgrade --install authentik authentik/authentik -f values.yaml --namespace authentik-ha --create-namespace 
