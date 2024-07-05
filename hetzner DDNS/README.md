This page is to create a script to bind dynamically the Hetzner DNS to your dynamic IP. It is specific taylored with the Hetzner's API and to use it you need to createthe API TOKEN.

First step write you API token in this file
```
sudo vim /etc/hetzner-ddns-credentials.txt
chmod 600 /etc/hetzner-ddns-credentials.txt
```

then download from this repo **ddns_multiple.sh** where you will need to change:
* **CREDENTIALS_FILE** - put the exact path if you use a different one
* **DOMAIN_NAME** - you root domain name like neptune87.cloud
* **RECORD_NAMES** - all the subdomains that you want to change the ip like nextcloud for nextcloud.neptune87.cloud

Also change the permission
```
sudo chmod +x ddns_multiple.sh
```
