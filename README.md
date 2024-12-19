# k3s-supreme-waffle
k3s-supreme-waffle goals is track the progress of an K3S home study project: **is not for a production envirorment**

**Several guide was followed to create this script, at the end of this page (and each sub directory page) you can find the full reference list.**

This repository contains script is to configure a **K3S cluster** in High Availability Embedded etcd with at least 3 server node. As O.S is used **Ubuntu 24.04 server AMD64**. 

This script was tested on a (old) laptop machine with Virtualbox on top, in this case is suggested 3 node with 1vcpu and 8gb ram each one.

This script was also test on Hetzner cloud service, in this case 3 node with 2vcpu (intel) 4gb ram each one works fine too.

In the root of this repository you can find several script for install K3S on main server node and additional node server, deploy longhorn and run a Wikijs/MariaDB web application for testing purpose.

The file in this root folder are:
* **K3S_first_UBUNTU.sh** - Run on the first server node, install K3S, Longhorn with all the dependencies, mariadb and wikijs by applying different yaml file. You need to edit it to change the ip of your machine in it;
* **K3S_second_server_UBUNTU.sh** - Install the additionals servers node. You need to change the TOKEN of your cluster, you can found it in your first server node installation;
* **wikijs-config.yaml** - Contains service and deployment of MariaDb;
* **wikijs-deployment.yaml** - Contains the deployment of Wikijs;
* **wikijs-secret.yaml** - Contains secret for the configruation of MariaDB, you need to edit it to change different user and password;
* **wikijs-pvc.yaml** - Contains the persistent volume claims using longhorn;
* **wikijs-pvc-local-path.yaml** - Alternative persistent volume claim using a local path on the node;
* **wikijs-service.yaml** - Contains the service;
* **restart-longhorn.sh** - Can be run in order to restart longhorn
* **mount-longhorn.yaml** - is an utility pod that start with your longhorn pvc mounted, useful to edit file with the vi command on longhorn volume. You can access it with the command kubectl -n < namespace > exec -it longhorn-editor -- sh
* **ingress.yaml** - ingress to expose longhorn frontend (or can be a template for other kind of front-end.

# Additional application for your server
If you want to continue your learning you can also follow this additional guide: 
* **/velero** - Is an application useful for schedule backup of the entire cluster on an external Bucket (AWS S3 or even a minio local server)
* **/minio** - Is an application useful to create your own bucket on your local machine. For development purphose you can run two different cluster and one of them having minio for keeping the backup made by velero
* **/cert-manager** - In an application used to manager your TLS certificate. Useful for application that need encryption like nextcloud
* **/nextcloud** - Is an application that can be used to storage file
* **/storagebox** - How to configure and mount an SSH folder on K3S, for example the Storage Box offered by hetzner. Is useful if you want to use an external storage for the data of nextcloud
* **/hardening** - Same hardening suggestions if your "home lab" is on the cloud
* **/prometheus-stack** - Prometheus stack, usefull to deploy a prometheus full stack with Grafana dashboard to monitor your K3S cluster
* **/imaginary** - Image preview generator, useful to be used with Nextcloud
* **/raspberrypi5** and **raspberrypi02w** - some test and configuration tested and work on Raspberry
* **/elasticsearc** - aggregating and monitor the log of your cluster
* **/pihole** - DNS server (and AD blocker) on K3S. Useful also if you want to resolve internal domain on your lan
* **/hetzner DDNS** - SH script that interact with hetzner DNS api for updating the ip of your DNS name
* **/Authentik** - Identity provider that you can integrate with Traefik in K3S
* **/Metallb** - software loadbalancer, very useful in case of multiple node cluster
* **/homer** - static light home page for your homelab


# Kubernetes useful commands
* **Change the replica number of an already existing deployment**
  * kubectl -n < namespace > scale deployment/< deployment_name > --replicas=0
* **Edit external IPs of a service already deployed and check the changes**
  * kubectl patch svc serviceName -n < namespace > -p '{"spec":{"externalIPs":["< Put.here.the.ip >"]}}'
  * kubectl describe service serviceName -n < namespace >
* **Get pod log**
  * kubectl logs < pod-specific-instance > -n < namespace > 
  * kubectl describe pod  <pod-specific-instance> -n < namespace >
* **Apply a Yaml file**
  * kubectl apply -f file.yaml
* **Get Yaml file of a deployment**
  * kubectl get deploy <deploymentName> -o yaml -n < namespace >
*  **Delete all resource in a namespace and then delete the namespace**
  *  kubectl delete all --all -n < namespace >
  *  kubectl delete namespace < namespace >
* **Delete a resource, like a PVC, stucked on terminating**
  * kubectl delete pvc nextcloud-db-pvc -n <namespace > --force –grace-period=0
* **Delete a namspace locked on Terminating status**
```
(
NAMESPACE=namespace
kubectl proxy &
kubectl get namespace $NAMESPACE -o json |jq '.spec = {"finalizers":[]}' >temp.json
curl -k -H "Content-Type: application/json" -X PUT --data-binary @temp.json 127.0.0.1:8001/api/v1/namespaces/$NAMESPACE/finalize
)
```
* **Some error checking error**
```
CRUL:
kubectl exec -n nextcloud nextcloud-6cb95f8c6d-fz6qx -- curl -v http://imaginary.imaginary.svc.cluster.local:9000

DNS CHECK:
kubectl run -i --tty dnsutils --image=busybox --restart=Never --rm --namespace nextcloud -- /bin/sh -c "nslookup imaginary.imaginary.svc.cluster.local"

ENTER IN THE POD AND NAVIGATE IT
kubectl exec -it nextcloud-6cb95f8c6d-2dtj2 -n nextcloud -- /bin/bash
```
* **Storage FIX (need to be unmounted. maybe attached with an external USB adapter)**
```
lsblk
sudo fsck -f -y /dev/sda2sudo fsck -f /dev/sda2
```
* **Assign label to a node**
```
kubectl label node ubuntu2 k3s-upgrade=server
```
* **Restore etcd snapshot on 1 node cluster**
```
/usr/local/bin/k3s server \
--cluster-reset \
--cluster-reset-restore-path=/var/lib/rancher/k3s/server/db/snapshots/etcd-snapshot-ubuntu1-1723888802
```
* **Restore etcd snapshot on 3 node cluster**
```
on each node:
systemctl stop k3s

on first node (the one used to initializate the Cluster the first time):
/usr/local/bin/k3s server \
--cluster-reset \
--cluster-reset-restore-path=/var/lib/rancher/k3s/server/db/snapshots/etcd-snapshot-ubuntu1-1724752804
systemctl start k3s

on other nodes (not first)
rm -rf /var/lib/rancher/k3s/server/db/
systemctl start k3s
```
* **Delete image from a node to force the download (work even with pullpolicy:ifnotpresent**
```
sudo crictl rmi nextcloud:stable
sudo ctr -n k8s.io images rm docker.io/library/nextcloud:stable
```


# Linux useful commands
* **Disable use of swap**
  * sudo swapoff -a
* **Enable use of swap**
  * sudo swapon -a
* **Disable IPV6**
  * net.ipv6.conf.all.disable_ipv6 = 1
  * net.ipv6.conf.default.disable_ipv6 = 1
  * net.ipv6.conf.lo.disable_ipv6 = 1
* **check disk mounted to the machine**
  * lsblk
* **Check the open port and open one port**
  * sudo ufw status
  * sudo ufw allow 6443/tcp
* **Check space used from a directory**
  * du -sh
* **Check disk usage**
  * df -h
* **Check number of file in a directory and sub directory**
  * find . -type f | wc -l
* **Check the space used by a directory and the number of file in it**
```
DIRECTORY="./"; echo "Total size: $(du -sh "$DIRECTORY" | awk '{print $1}')"; echo "Total number of files: $(find "$DIRECTORY" -type f | wc -l)"
```
* **Different command to check log on linux (tested on ubuntu 24.04)**
```
List of reboot
last reboot

List of error in the last 2 days
journalctl --since "2 days ago" -p 3

Journalctl general LOG:
sudo journalctl --since "2024-08-02 04:29" --until "2024-08-02 04:35"

Journalctl LOG only for K3S:
sudo journalctl -u k3s --since "2024-08-02 04:29" --until "2024-08-02 04:35"

Journalctl LOG only for SSH:
sudo journalctl -u ssh --since "2024-08-02 04:29" --until "2024-08-02 04:35"

NETWORK LOG:
sudo grep "wlan0" /var/log/syslog | awk '$0 ~ /2024-07-28T02:/'

AUTH LOG:
sudo grep "error\|fail\|critical" /var/log/auth.log | grep "2024-07-29T02:"

ALL K3S container log:
grep -i "error\|fail\|critical" /var/log/containers/*.log
grep '2024-07-29T11:' /var/log/containers/*.log | grep -i 'error\|fail\|critical'

CHECK NVME
journalctl --since "2 days ago" | grep -i nvme
sudo journalctl --since "7 days ago" | grep "controller is down"
```
* **DNS setting (tested on ubuntu 24.04)**
```
sudo systemctl stop systemd-resolved 
sudo systemctl disable systemd-resolved

sudo rm /etc/resolv.conf 
echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" | sudo tee /etc/resolv.conf

sudo systemctl restart systemd-networkd
```
* **Check video configuration**
```
lshw -C display
lspci -nn | grep -Ei "3d|display|vga"
```
* **TOP commmand but for gpu**
```
sudo apt install intel-gpu-tools
intel_gpu_top
```

**References:**
* **K3S install**: https://documentation.suse.com/trd/kubernetes/single-html/kubernetes_ri_k3s-slemicro/index.html
* **WIKI.JS install**:  https://computingforgeeks.com/install-and-configure-wikijs-on-kubernetes-cluster/
* **Install helm3 on K3S**: https://www.virtono.com/community/tutorial-how-to/how-to-install-k3s-cluster-and-helm/
* **Kubernetes persisten volume configuration**: https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/
* **Longhorn envirorment check**: https://longhorn.io/docs/1.6.1/deploy/install/#installation-requirements
* **Longhorn helm installation**: https://longhorn.io/docs/1.6.1/deploy/install/install-with-helm/
* **Kubectl dashboard installation**: https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
* **Postgresql deploy references**:
  * https://www.digitalocean.com/community/tutorials/how-to-deploy-postgres-to-kubernetes-cluster
  * https://github.com/testdrivenio/node-kubernetes/blob/master/kubernetes/postgres-deployment.yaml
  * https://github.com/mendix/kubernetes-howto/blob/master/postgres-deployment.yaml
  * https://medium.com/swlh/deploy-wiki-js-on-kubernetes-686cec78b29
* **Disable IPV6 on ubuntu**: https://intercom.help/privatevpn/en/articles/6440374-how-to-disable-ipv6-on-ubuntu-and-fedora-linux
* **Micro OS easy ssh enrollment**: https://microos.opensuse.org/blog/2024-05-17-ssh-pairing/
* **Micro OS change hostname**: https://www.simplified.guide/suse/change-hostname
* **How to delete all resources from Kubernetesd**: https://stackoverflow.com/questions/47128586/how-to-delete-all-resources-from-kubernetes-one-time


**Disclaimer:** some of this references wasn't used in the script but was useful for the learning purpose.
