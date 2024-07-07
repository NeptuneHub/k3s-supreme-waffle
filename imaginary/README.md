**Imaginary** is an application that can process an image genereting a preview just calling an url. This plugin is very useful with Nextcloud for the preview of JPG email.

First things you need to deploy it, for this just downaload the deployment.yaml in this repository and apply it by

```
kubectl apply -f deployment.yaml
```

After that, to use it with nextcloud you need to edit your config.php. In my deployment of Nextcloud, using as a pvc local-path, I have it in this position:
```
/var/lib/rancher/k3s/storage/pvc-c7f870cc-06b6-4d27-af5f-c5489bb4c520_nextcloud_nextcloud-server-pvc/config
```

In confing.php you can add this line:
```
  'enable_previews' => true,
  'preview_max_x' => '2048',
  'preview_max_y' => '2048',
  'jpeg_quality' => '60',
  'enabledPreviewProviders' => [
    'OC\Preview\MP3',
    'OC\Preview\TXT',
    'OC\Preview\MarkDown',
    'OC\Preview\OpenDocument',
    'OC\Preview\Krita',
    'OC\Preview\Imaginary',
],
'preview_imaginary_url' => 'http://imaginary.imaginary.svc.cluster.local:9000',
'preview_imaginary_signature_key' => 'YOUR-LONG-KEY-HERE-SAME-OF-DEPLOYMENT',
'allow_local_remote_servers' => true,
```

where:
* the first 4 line just give the format of the preview image, avoiding to have image to big
* enablePreviewProvider specify for what kind of document you are using it
* preview_imaginary_url is the url of your new deployment using the local K3S dns. If you deployed the SVC in a differnet namespace just change it
* preview_imaginary_signature_key is the secret key to allow only authorized people to use it. This is the same that you need to configure in the deployment.yaml.


# Preview generator
This plugin work also good with image preview app (you can install it directly from the Nextcloud application store). Is an application that allow you to schedule the creation of the resized image (otherwise nextcloud create it only when the user access to nextcloud and navigate on a specific image).

If you install nextcloud preview generator, you need to run this command at the beggining to create all the initial image (this command is tailored to be executed on Kubernetes deployment):
```
kubectl exec --stdin --tty -n nextcloud $(kubectl get pods -n nextcloud -o jsonpath="{.items[*].metadata.name}" | grep nextcloud) -- su -s /bin/sh www-data -c "php occ preview:generate-all"
```

then create the cron job in order to keep to create the image preview for the new uploaded image each 10 minutes:

```
crontab -e
```

and put:
```
*/10 * * * * kubectl exec --stdin --tty -n nextcloud $(kubectl get pods -n nextcloud -o jsonpath="{.items[*].metadata.name}" | grep nextcloud) -- su -s /bin/sh www-data -c "php occ preview:pre-generate"
```

If you want to reset che preview created, cancel all the content of this directory (remember to change the name of the pvc)

```
rm -r /var/lib/rancher/k3s/storage/pvc-c7f870cc-06b6-4d27-af5f-c5489bb4c520_nextcloud_nextcloud-server-pvc/data/appdata_ochh36t2kwgk/preview/
```

then run this command to reset the db of the image:

```
kubectl exec --stdin --tty -n nextcloud $(kubectl get pods -n nextcloud -o jsonpath="{.items[*].metadata.name}" | grep nextcloud) -- su -s /bin/sh www-data -c "php occ files:scan-app-data"
```

And finally re-start the generation as a first installation

```
kubectl exec --stdin --tty -n nextcloud $(kubectl get pods -n nextcloud -o jsonpath="{.items[*].metadata.name}" | grep nextcloud) -- su -s /bin/sh www-data -c "php occ preview:generate-all"
```


**References:**
* **Deploy immaginary on kubernetes** - https://itnext.io/how-to-build-your-own-secure-image-processing-service-with-imaginary-and-kubernetes-cf124649047c
* **Imaginary Github** - https://github.com/h2non/imaginary
* **Nextcloud documentation** - https://docs.nextcloud.com/server/latest/admin_manual/installation/server_tuning.html
* **Preview generator** - https://github.com/nextcloud/previewgenerator
