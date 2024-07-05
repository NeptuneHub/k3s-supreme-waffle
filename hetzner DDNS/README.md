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

Now edit the crontab
```
sudo crontab -e
```

and add this line to run the script each 10 minutes setting the exact path of the script
```
*/10 * * * * /bin/bash /root/ddns_multiple.sh
```

References:
* **Hetzner API token** - https://docs.hetzner.com/dns-console/dns/general/api-access-token/
