First you need to **install che CLI part**, so check here the last version of velero:
* https://github.com/vmware-tanzu/velero/releases/tag/v1.13.2

Download it to the machine:
```
wget https://github.com/vmware-tanzu/velero/releases/download/v1.13.2/velero-v1.13.2-linux-amd64.tar.gz
```

Decompress the file
```
tar -xzvf velero-v1.13.2-linux-amd64.tar.gz
```

Copy the velero executable in the appropriate directory, tipically:
```
mv velero /usr/local/bin/
```

**Important:** 
* CLI VERSION AND PLUGIN VERSION NEED TO BE COMPATIBLE
* In our test we used velero-v1.14.0-rc.1-linux-amd64 and   velero/velero-plugin-for-aws:v1.10.0-rc.1

Now running the command Velero you can proceed with install the Kubernetes part and next you will also use it to run backup, restore them and so on.

For the server part first you need to create your S3 compatible bucket.  If you use AWS remember also to create a new user, assign to him the S3 Policy in order to work with the bucket and get his aws_access_key_id and aws_secret_access_key.

With the credential create the credential file like this
```
[default]
aws_access_key_id=xxxxxxx
aws_secret_access_key=yyyyyyyyyyy
```

Now you can run the install, for example to install it on AWS the command could be like this
```
velero install --provider aws --bucket volera-neptune87 --secret-file ./credentials-velero2 --backup-location-config region=eu-north-1 --snapshot-location-config region=eu-north-1 --plugins velero/velero-plugin-for-aws:v1.10.0-rc.1 --use-node-agent --default-volumes-to-fs-backup
```



**Refrences:**
* **Velero for oracle cloud** -  https://blogs.oracle.com/cloud-infrastructure/post/backing-up-your-oke-environment-with-velero
* **Velero aws plugin** - https://github.com/vmware-tanzu/velero-plugin-for-aws
* **Velero official documentation** https://velero.io/docs/v1.14/contributions/oracle-config/*
