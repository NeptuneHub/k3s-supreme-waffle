Minio is useful to deploy on K3S a local simil S3 bucket for testing purpose.

First you need to download the yaml and apply it on your cluster

```
curl https://raw.githubusercontent.com/minio/docs/master/source/extra/examples/minio-dev.yaml -O
kubectl apply -f minio-dev.yaml
```

Then you need to apply this service:
* minio-svc.yaml - in order to reach the web console from your browser, remember to change you machine ip address;
* minio-svc-interl.yaml - in order to look the APi address for the velero installation

After that the console can be view in an address like this:
```
http://192.168.1.69:9001/buckets
```
And here you can login with user and password **minioadmin** and create your bucket and your secret

In this case your velero installation on your K3S cluster will be like this (remember to change the IP address):
```
velero install --provider aws --plugins velero/velero-plugin-for-aws:v1.10.0-rc.1 --bucket neptune87 --secret-file ./credentials-velero-minio --use-volume-snapshots=false --backup-location-config region=minio,s3ForcePathStyle="true",s3Url=http://192.168.1.69:9000 --use-node-agent –default-volumes-to-fs-backup
```

