# Introduction
In this page I'll collect the result of my test on a Raspberry Pi 0 2W that work with an internal SD card

#K3S Agent
My first attemp is to install K3S as an agent, due to the small ram (K3S require at least 1GB). You can do by using this command:

```
curl -sfL https://get.k3s.io | K3S_URL=https://<your-master-node-ip>:6443 K3S_TOKEN=<your_token> sh -i
```

If you have error in installation, remember to check the open port on the main server. You can get more information in the ./hardening section of this repo.

#Pihole on K3S agent
Deploying Pihole on K3S agent that n on Raspberry Pi 0 2w is totally possible with the 512 mb for an home using.

To say to K3S on which node to deploy pihole, we assing this lable to our 2-node cluster (where ubunut1 is the master and ubuntu2 is the PI 0 2w):

```
kubectl label nodes ubuntu1 app=high --overwrite 
kubectl label nodes ubuntu2 app=low --overwrite
```
You can also check the result wuith:

```
kubectl get nodes --show-labels
```

Then you can deploy pihole using the label "app=low" lby applying the deployment in this repo:
```
kubectl apply -f deployment.yaml
```

