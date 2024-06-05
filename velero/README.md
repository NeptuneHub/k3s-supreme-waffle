First you need to install che CLI part, so check here the last version of velero:
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


Refrences:
* **Velero for oracle cloud** -  https://blogs.oracle.com/cloud-infrastructure/post/backing-up-your-oke-environment-with-velero
* **Velero aws plugin** - https://github.com/vmware-tanzu/velero-plugin-for-aws
* **Velero official documentation** https://velero.io/docs/v1.14/contributions/oracle-config/*
