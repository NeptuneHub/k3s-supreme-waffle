# Introduction
Authentik itself is stateless so just put to 3 the replica of server and worker on 3 different node (on a K3S HA deployment) is enough for itself.

Anyway Authentik use Redis cache and PostgresqlDB and the one embeded in the helmchart seems don't allow the HA itself. To do that we used zalando cluster for Postgresql AND Dragonfly instead of redis.

# Install postgresql in HA with zalando

First we need to install the zalando operator, this will help in creating the database
```
kubectl create namespace authentik-ha
helm repo add postgres-operator-charts https://opensource.zalando.com/postgres-operator/charts/postgres-operator
helm install postgres-operator postgres-operator-charts/postgres-operator --namespace zalando-op --create-namespace --values zalando-op-values.yaml
```

IF you want you can also deploy the graphical interface
```
helm repo add postgres-operator-ui-charts https://opensource.zalando.com/postgres-operator/charts/postgres-operator-ui
helm install postgres-operator-ui postgres-operator-ui-charts/postgres-operator-ui --namespace zalando-op --create-namespace
kubectl apply -f zalando-ingress.yaml
```

Now you can create the database deployment from the operator ui or you can directly use the one attached here:
```
kubectl apply -f zalando-deplyment.yaml
```

And you can get the password of the user namer **user** with this command:
```
kubectl get secret user.database.credentials.postgresql.acid.zalan.do -n authentik-ha -o jsonpath="{.data.password}" | base64 --decode && echo
```

Now you should have in the namespace authentik-ha 3 database pod and the **database-pooler** svc that will be the one to use as host for authentik.

# Install Dragonfly in HA instead of redis

Dragonfly is an alternative compatible with redis that work good.

First you can install the dragonfly operator with this command:
```
kubectl apply -f https://raw.githubusercontent.com/dragonflydb/dragonfly-operator/main/manifests/dragonfly-operator.yaml
```

Then you can deploy dragonfly in HA with the  **dragonfly-deployment.yaml** in this repo. Before deploy it remember to configure the password in the secret, it will be the one that you will need to configure in authentik.
```
kubectl apply -f dragonfly-deployment.yaml
```

Now you should have the 3 dragonfly node in atuhentik-ha namespace. Also you will have the **dragonfly** svc.

# Install Authentik in HA

To install Authentik in ha the main part that change are the **auth-values.yaml** the other are similar to the "not ha" configuration. Remember to edit the values to edit your password.
```
helm upgrade --install authentik authentik/authentik -f auth-values.yaml --namespace authentik-ha
kubectl apply -f ingress.yaml
kubectl apply -f middleware.yaml
kubectl apply -f service-ingress-route.yaml
```

And finally we can finalize the installation going here (edit the domain based on your ingress.yaml):
```
https://auth.silverycat.de/if/flow/initial-setup/
```
# Refenrece
* **Dragonfly k8s operator** - https://www.dragonflydb.io/docs/getting-started/kubernetes-operator#installation
* **Dragonly HA** - https://www.dragonflydb.io/docs/managing-dragonfly/high-availability
* **Zalando Postgre operator** - https://github.com/zalando/postgres-operator
* **Zalando quick start** - https://github.com/zalando/postgres-operator/blob/master/docs/quickstart.md#deployment-options
* **Zalnado cluster manifest reference** - https://github.com/zalando/postgres-operator/blob/master/docs/reference/cluster_manifest.md
