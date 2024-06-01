# k3s-supreme-waffle
k3s-supreme-waffle goals is track the progress of an K3S home study project: **is not for a production envirorment**

This repository contains script is to configure a **K3S cluster** in High Availability Embedded etcd with at least 3 server node. As O.S is used **Ubuntu 24.04 server AMD64**



Additional application installed on the cluster are:
* Longhorn for distribusted storage;
* Wikijs and Mariadb in order to have a web application to test.

The file shared are:
* **K3S_auto_UBUNTU.sh** => Install the first server node, install longhorn with all the dependencies, mariadb and wikijs by applying different yaml file
