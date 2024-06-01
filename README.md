# k3s-supreme-waffle
k3s-supreme-waffle goals is track the progress of an K3S home study project: **is not for a production envirorment**

**Several guide was followed to create this script, at the end of this page you can find the full reference list.**

This repository contains script is to configure a **K3S cluster** in High Availability Embedded etcd with at least 3 server node. As O.S is used **Ubuntu 24.04 server AMD64**

Additional application installed on the cluster are:
* Longhorn for distribusted storage;
* Wikijs and Mariadb in order to have a web application to test.

The file shared are:
* **K3S_auto_UBUNTU.sh** - Run on the first server node, install K3S, Longhorn with all the dependencies, mariadb and wikijs by applying different yaml file. You need to edit it to change the ip of your machine in it;
* **K3S_second_server.sh** - Install the additionals servers node. You need to change the TOKEN of your cluster, you can found it in your first server node installation;
* **wikijs-config.yaml** - Contains service and deployment of MariaDb;
* **wikijs-deployment.yaml** - Contains the deployment of Wikijs;
* **wikijs-secret.yaml** - Contains secret for the configruation of MariaDB, you need to edit it to change different user and password;
* **wikijs-pvc.yaml** - Contains the persistent volume claims;
* **wikijs-service.yaml** - Contains the service;
* **postgresql** - Is a working in progress (still not completed) to deploy wikijs on top of Postgresql instead of MariaDB.

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


**Disclaimer:** some of this references wasn't used in the script but was useful for the learning purpose.
