In this document we will support you in the configuration of nextcloud on your K3S cluster.

First you need to create the namespace
```
kubectl create namespace nextcloud
```

If you don't have helm you also needto install it
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

you also need to create a PVC called nextcloud-server-pvc
```
kubectl apply -f nextcloud-server-pvc.yaml
```


Now you can run the install command remember to edit:
* **nextcloud.host** - put you domain if you have one, or add the ip of your machine.
* **persistence.storageClass** - we used the local path storage, but if you had longhorn (or a different one) you can also use it

```
helm install nextcloud nextcloud/nextcloud \
--set nextcloud.host=next.neptune87.cloud \
--set persistence.enabled=true \
--set persistence.storageClass=local-path \
--set persistence.existingClaim=nextcloud-server-pvc \
--namespace nextcloud
```

After the installation, if you don't have specific networking configurartion, will be also useful assign to the nextcloud service the external ip of your node. In this way will be reachable from the extern.
```
kubectl patch svc nextcloud -n nextcloud -p '{"spec":{"externalIPs":["MACHINE-IP-HERE"]}}'
```

Now your nextcloud configuration will be visible at
```
next.neptune87.cloud:8080 or youipmachine:8080
```

default admin user will be
```
user: admin
password: changeme
```

After the first login you can change the password directly from the webapp.


Refrences
* **Nextcloud github** - https://github.com/nextcloud/helm/tree/main/charts/nextcloud
* **Nextcloud helm chart** - https://nextcloud.github.io/helm/
