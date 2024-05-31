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
curl -sfL https://get.k3s.io | sh -s - server --cluster-init

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

echo "Install longhorn"
sudo apt-get install nfs-client
kubectl version
sudo apt-get install jq
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.6.2/deploy/prerequisite/longhorn-iscsi-installation.yaml
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.6.2/deploy/prerequisite/longhorn-nfs-installation.yaml
curl -sSfL https://raw.githubusercontent.com/longhorn/longhorn/v1.6.2/scripts/environment_check.sh | bash
sh ./environment_check.sh

sleep 10s    
sleep 10s

helm repo add longhorn https://charts.longhorn.io
helm repo update
helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.6.2

sleep 1m

kubectl -n longhorn-system get pod
kubectl -n longhorn-system get svc
kubectl create -f https://raw.githubusercontent.com/longhorn/longhorn/v1.6.1/examples/storageclass.yaml
kubectl create namespace wikijs
sleep 1m

echo "install wiki"
kubectl apply -f wikijs-pvc.yaml
kubectl get namespaces
kubectl apply -f wikijs-secret.yaml
kubectl apply -f wikijs-config.yaml -n wikijs
kubectl get deployment -n wikijs
kubectl get pods -n wikijs
kubectl apply -f wikijs-service.yaml
kubectl get svc -n wikijs
kubectl apply -f wikijs-deployment.yaml

kubectl get deploy -n wikijs
kubectl get pods -n wikijs

echo "expose Longhorn and Wikijs service"
#modify the ip in the patch command with the local ip of your machine
kubectl patch svc wikijs -n wikijs -p '{"spec":{"externalIPs":["192.168.1.62"]}}'
kubectl describe service wikijs -n wikijs
kubectl patch svc longhorn-frontend -n longhorn-system -p '{"spec":{"externalIPs":["192.168.1.62"]}}'
kubectl describe service longhorn-frontend -n longhorn-system

echo "full Install complete"