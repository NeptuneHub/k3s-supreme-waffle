Imaginary is an application that can process an image genereting a preview just calling an url. This plugin is very useful with Nextcloud for the preview of JPG email.

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
```

where:
* the first 4 line just give the format of the preview image, avoiding to have image to big
* enablePreviewProvider specify for what kind of document you are using it
* preview_imaginary_url is the url of your new deployment using the local K3S dns. If you deployed the SVC in a differnet namespace just change it
* preview_imaginary_signature_key is the secret key to allow only authorized people to use it. This is the same that you need to configure in the deployment.yaml.



**References:**
* **Deploy immaginary on kubernetes** - https://itnext.io/how-to-build-your-own-secure-image-processing-service-with-imaginary-and-kubernetes-cf124649047c
* **Imaginary Github** - https://github.com/h2non/imaginary
* **Nextcloud documentation** - https://docs.nextcloud.com/server/latest/admin_manual/installation/server_tuning.html
