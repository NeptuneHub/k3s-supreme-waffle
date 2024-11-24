# Introduction
This how to is to install Synapse home server for Matrix AND element as a web chat on your homelab. This will be used also send and receive notification from the homelab server (like from uptime kuma).

# Install
The installation is with helm by using this commands:

```
helm repo add matrix https://remram44.github.io/matrix-helm
kubectl create namespace chat
helm install chat matrix/matrix --namespace chat -f values.yaml
```
