#!/bin/bash

# example of using arguments to a script
echo "Unistall K3S old version"
/usr/local/bin/k3s-uninstall.sh

sleep 5s

#Install other dependencies
echo "Install dependencies"
sudo apt-get install open-iscsi
sudo systemctl enable iscsid
sudo systemctl start iscsid


echo "Reinstall K3S last version"
#change the url and the token of the primary server here
#you can find it in your first k3s server node at this path: /var/lib/rancher/k3s/server/token
curl -sfL https://get.k3s.io | K3S_TOKEN=YOUR_TOKEN_HERE sh -s - server --server https://192.168.1.64:6443 \


sleep 5s
#systemctl status k3s
kubectl get service

rm $HOME/.kube/config
mkdir -p $HOME/.kube
sudo cp -i /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo chown $(id -u):$(id -g) /etc/rancher/k3s/k3s.yaml

kubectl get service

sleep 10s

echo "Install helm"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh


echo "Install K3S second server complete"
