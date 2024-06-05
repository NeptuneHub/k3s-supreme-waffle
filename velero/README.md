Velero is an application that you can use to make backup of the entire K3S (volume, deployment, service, and so on) and is composed by a CLI part and the POD part that run on the cluster.

The backup is made on a Bucket, several are support (about this look the official references). We used it with AWS S3 Bucket AND with a local deployment of minio (that is also S3 compatible).

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

With the credential create the file **credentials-velero** like this (change xxxxxxx and yyyyyyyyyyy with you secret)
```
[default]
aws_access_key_id=xxxxxxx
aws_secret_access_key=yyyyyyyyyyy
```

Now you can run the install, for example to install it on AWS the command could be like this
```
velero install --provider aws --bucket volera-neptune87 --secret-file ./credentials-velero --backup-location-config region=eu-north-1 --snapshot-location-config region=eu-north-1 --plugins velero/velero-plugin-for-aws:v1.10.0-rc.1 --use-node-agent --default-volumes-to-fs-backup
```

Where the explanetion is:
```
--provider aws: Specifies the cloud provider. In this case, it's set to Amazon Web Services (AWS).

--bucket volera-neptune87: Specifies the S3 bucket where Velero stores backup data. In this example, the bucket is named "volera-neptune87".

--secret-file ./credentials-velero: Specifies the file containing AWS credentials. Velero needs these credentials to access the AWS resources for backup and restore operations.

--backup-location-config region=eu-north-1: Specifies the region where Velero should store backups. In this case, it's set to "eu-north-1", which is an AWS region.

--plugins velero/velero-plugin-for-aws:v1.10.0-rc.1: Specifies any plugins that Velero should use. In this case, it's specifying the version 1.10.0-rc.1 of the Velero plugin for AWS.

--use-node-agent: Indicates that Velero should use the node agent for backups. This flag is used when you want Velero to perform backups directly from the nodes in your Kubernetes cluster.

--default-volumes-to-fs-backup: Specifies that Velero should default to file system backups for volumes. This means that Velero will back up volumes using file system snapshots rather than block storage snapshots.
```

You can check that the installation went fine running this command:
```
NAME      PROVIDER   BUCKET/PREFIX   PHASE       LAST VALIDATED                   ACCESS MODE   DEFAULT
default   aws        neptune87       Available   2024-06-06 00:12:10 +0200 CEST   ReadWrite     true
```

If after some second the Phase become from Unknow to Avaiable the conenction should be ok. if not, the pod maybe is not started or you have some connection configruation problem.

Som useful command are:
* **Create a full backup**:
  * velero backup create backup-full --default-volumes-to-fs-backup
* **Get the list of backup**
  * velero backup get
* **Restore a backup**
  * velero restore create --from-backup backup-full
* **Schedule arecurrent backup every 6h with retention 24h** 
  * velero schedule create backup-every-6h --schedule="0 */6 * * *" --ttl "24h" --include-namespaces="*" --default-volumes-to-fs-backup

**Refrences:**
* **Velero for oracle cloud** -  https://blogs.oracle.com/cloud-infrastructure/post/backing-up-your-oke-environment-with-velero
* **Velero aws plugin** - https://github.com/vmware-tanzu/velero-plugin-for-aws
* **Velero official documentation** https://velero.io/docs/v1.14/contributions/oracle-config/*
