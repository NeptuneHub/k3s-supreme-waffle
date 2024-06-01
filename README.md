# k3s-supreme-waffle
k3s-supreme-waffle goals is track the progress of an K3S home study project: **is not for a production envirorment**

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
