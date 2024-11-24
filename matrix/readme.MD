# Introduction
This how to is to install Synapse home server for Matrix AND element as a web chat on your homelab. This will be used also send and receive notification from the homelab server (like from uptime kuma).

# Install
The installation is with helm by using this commands **values.yaml**, remeber to change:

* All the server name and base url
* the cluster issuer name for the https certificate
* **enable_registration** and **enable_registration_without_verification** are initially to false to avoid registration . You can enable to create your used and then disable.

Then just proceed with the installation by running this commands:
```
helm repo add matrix https://remram44.github.io/matrix-helm
kubectl create namespace chat
helm install chat matrix/matrix --namespace chat -f values.yaml
```
