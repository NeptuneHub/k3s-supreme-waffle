In this document we will support you in the configuration of nextcloud on your **K3S cluster** with or without the use of TLS.

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
**Important** - if you want to configure nextcloud with TLS support skip this install command and go directly to **CONFIGURATION WITH TLS** chapter.

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

# CONFIGURATION WITH TLS

To avoid lower the probability of a man in the middle attack is strongly useful to use a TLS certifcate. To do that follow all the previous step, just skip the **helm install nextcloud** command and proceed with this other step.

First you need to create your certificate, in case of self-signed certificate you can follow this command
```
openssl req -x509 -nodes -days 36500 -newkey rsa:2048 -keyout next.neptune87.cloud.key -out next.neptune87.cloud.crt
base64 -w 0 next.neptune87.cloud.crt > cert_base64.txt
base64 -w 0 next.neptune87.cloud.key > key_base64.txt
```

you then need to put the output of the two file in **next-neptune87-cloud-tls-secret.yaml** and apply it
```
kubectl apply -f next-neptune87-cloud-tls-secret.yaml
```
Now because the parameter to pass become more, we will use the values.yaml file to proceed with the installation.

**Important** - edit the file with your information before lunch the command.

To proceed with the installation use the command:
```
 helm install nextcloud nextcloud/nextcloud --namespace nextcloud -f values.yaml
``` 

With this new values.yaml we simply asked to create an ingress using the tls certificate created. You can check the created ingress with this command:

```
kubectl get ingress -n nextcloud
```

In nextcloud values-yaml we put as ingress nginx BUT K3S use by defaul traefik, you can edit the created ingress with thiscommand
```
kubectl edit ingress nextcloud -n nextcloud
``` 

and set ingressClassName trafic like this

``` 
spec:
  ingressClassName: traefik
```

If you have a valid DNS name you can register a public certificate with let's encrypt by using this command:

```
sudo certbot certonly --standalone -d next.neptune87.cloud
```
**Important** - Other step could be needed for the public certificate, I need to compelte this guide.

**Refrences**
* **Nextcloud github** - https://github.com/nextcloud/helm/tree/main/charts/nextcloud
* **Nextcloud helm chart** - https://nextcloud.github.io/helm/
