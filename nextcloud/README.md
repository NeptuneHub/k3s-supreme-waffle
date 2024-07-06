# Install
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
helm repo add nextcloud https://nextcloud.github.io/helm/
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

# config.php
The file **config.php** will keep most useful configuration after your nextcloud install. It could be found in a path like this:
```
/var/lib/rancher/k3s/storage/pvc-7bcfa367-27ab-4ec3-8437-04aaf2b7131e_nextcloud_nextcloud-server-pvc/config
```

**trusted_domains** specify the domains associated to your installation, only from this url you will be able to use nextcloud:
```
  'trusted_domains' =>
  array (
    0 => 'localhost',
    1 => 'store2.silverycat.de',
  ),
```

**trusted_proxies** are the trusted ip, the suggestion is to place it your ip to avoid the anti-ddos attack can accidenlty look your ip:
```
  'trusted_proxies' =>
  array (
    0 => '<YOUR IP>',
  ),
```

If you followed the configuration of **/immaginary** on this repo yu will need to add this configuration:
```
  'enable_previews' => true,
  'jpeg_quality' => '60',
  'preview_max_x' => '1024',
  'preview_max_y' => '1024',
  'preview_max_scale_factor' => 1.5,
  'enabledPreviewProviders' =>
  array (
    0 => 'OC\\Preview\\MP3',
    1 => 'OC\\Preview\\TXT',
    2 => 'OC\\Preview\\MarkDown',
    3 => 'OC\\Preview\\OpenDocument',
    4 => 'OC\\Preview\\Krita',
    5 => 'OC\\Preview\\Imaginary',
  ),
  'preview_imaginary_url' => 'http://imaginary.imaginary.svc.cluster.local:9000',
```

# CONFIGURATION WITH TLS SELF-SIGNED

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
helm repo add nextcloud https://nextcloud.github.io/helm/
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

# CONFIGURATION WITH TLS Let's Encrypt

If you want to use a let's encrypt certificate using certmanager, first install cert-manager (check the **/cert-manager guide**). 

You can sart the step with the self-signed certificate and this are additional step to complete it.


You need to edit another time the ingress
```
kubectl edit ingress nextcloud -n nextcloud
```

and add this under annotation:
```
annotations:
cert-manager.io/cluster-issuer: letsencrypt-production
``` 

Now you ken check that the certificate is issued correctly getting certificaterequest and certificate, you will receive a result like this:

``` 
root@ubuntu:~/Documents/cert-manager# kubectl get certificaterequest -n nextcloud -o wide
NAME                         APPROVED   DENIED   READY   ISSUER                   REQUESTOR                                         STATUS                                         AGE
next-neptune87-cloud-tls-1   True                True    letsencrypt-production   system:serviceaccount:cert-manager:cert-manager   Certificate fetched from issuer successfully   4s
root@ubuntu:~/Documents/cert-manager# kubectl get certificaterequest -n nextcloud -o wide
NAME                         APPROVED   DENIED   READY   ISSUER                   REQUESTOR                                         STATUS                                         AGE
next-neptune87-cloud-tls-1   True                True    letsencrypt-production   system:serviceaccount:cert-manager:cert-manager   Certificate fetched from issuer successfully   7s
root@ubuntu:~/Documents/cert-manager# kubectl get certificate -n nextcloud -o wide
NAME                       READY   SECRET                     ISSUER                   STATUS                                          AGE
next-neptune87-cloud-tls   True    next-neptune87-cloud-tls   letsencrypt-production   Certificate is up to date and has not expired   10m
root@ubuntu:~/Documents/cert-manager#
```

After creating the certificate for nextcloud remember to export a backup in this way (change the name of the secret and the name of the namespace for your configuration):
```
kubectl get secret next-neptune87-cloud-tls -n nextcloud -o yaml > store-next-neptune87-cloud-tls.yaml
```

When you need to re-import the certificate you just need to run this command (before re-deploy the application)
```
kubectl apply -f store-next-neptune87-cloud-tls.yaml
```

# Configure Nextcloud on S3 like bucket
To configure a bucket S3 like to be used as primary storage you need to edit the config.php. If you configured nextcloud PVC as local-path you will find your pvc here:


```
cd /var/lib/rancher/k3s/storage/YOURPVCNAME/config/config.php

```

at this point you can add this (following the format of the file) this string:

```
  'objectstore' => [
        'class' => '\\OC\\Files\\ObjectStore\\S3',
        'arguments' => [
                'bucket' => 'PUT BUCKET NAME',
                'hostname' => 'PUT BUCKET URL',
                'key' => 'PUT YOUR KEY',
                'secret' => 'PUT YOUR SECRET',
                'port' => 'PUT YOUR PORT',
                // required for some non-Amazon S3 implementations
                'use_path_style' => true, 
        ],
],
```

here you need to add the information of your bucket.

# Update the DB
If you add file directly in the directory of nextcloud (so on the OS without passing from nextcloud), maybe because you restored a backup, you need to resync the index of nextcloud otherwise you will never see the new image.

For do that you can run this command (supposing that you installed nextclod in the namespace nextcloud):
```
kubectl exec --stdin --tty -n nextcloud $(kubectl get pods -n nextcloud -o jsonpath="{.items[*].metadata.name}" | grep nextcloud) -- su -s /bin/sh www-data -c "php occ files:scan --all"
```

If this command give error because of permission after the copy of the image, you can fix it inerithing the ownership and permission of the copied folder from the pre-existing father.
I run this command for example for the user admin and emma.

Before run it you need to change all the path of the folder changed. This also suppose that you install nextcloud on localpath:

```
# Fix permissions and ownership for admin directory
sudo chmod -R --reference=/var/lib/rancher/k3s/storage/pvc-7bcfa367-27ab-4ec3-8437-04aaf2b7131e_nextcloud_nextcloud-server-pvc/data/admin/files /var/lib/rancher/k3s/storage/pvc-7bcfa367-27ab-4ec3-8437-04aaf2b7131e_nextcloud_nextcloud-server-pvc/data/admin/files/admin
sudo chown -R --reference=/var/lib/rancher/k3s/storage/pvc-7bcfa367-27ab-4ec3-8437-04aaf2b7131e_nextcloud_nextcloud-server-pvc/data/admin/files /var/lib/rancher/k3s/storage/pvc-7bcfa367-27ab-4ec3-8437-04aaf2b7131e_nextcloud_nextcloud-server-pvc/data/admin/files/admin

# Fix permissions and ownership for emma directory
sudo chmod -R --reference=/var/lib/rancher/k3s/storage/pvc-7bcfa367-27ab-4ec3-8437-04aaf2b7131e_nextcloud_nextcloud-server-pvc/data/emma/files /var/lib/rancher/k3s/storage/pvc-7bcfa367-27ab-4ec3-8437-04aaf2b7131e_nextcloud_nextcloud-server-pvc/data/emma/files/emma
sudo chown -R --reference=/var/lib/rancher/k3s/storage/pvc-7bcfa367-27ab-4ec3-8437-04aaf2b7131e_nextcloud_nextcloud-server-pvc/data/emma/files /var/lib/rancher/k3s/storage/pvc-7bcfa367-27ab-4ec3-8437-04aaf2b7131e_nextcloud_nextcloud-server-pvc/data/emma/files/emma
```


**Refrences**
* **Nextcloud github** - https://github.com/nextcloud/helm/tree/main/charts/nextcloud
* **Nextcloud helm chart** - https://nextcloud.github.io/helm/
* **Deploy nextcloud on kubernetes guide** - * https://greg.jeanmart.me/2020/04/13/deploy-nextcloud-on-kuberbetes--the-self-hos/
* **Nexctloud S3 bucket** - https://docs.nextcloud.com/server/13/admin_manual/configuration_files/primary_storage.html#simple-storage-service-s3
