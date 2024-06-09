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



Refrences
* **Nextcloud github** - https://github.com/nextcloud/helm/tree/main/charts/nextcloud
* **Nextcloud helm chart** - https://nextcloud.github.io/helm/
