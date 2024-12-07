# Introduction
This is to install Collabora online on K3S and then configure Nextcloud to integrate with it

# Install collabora

You can install collabora with the helm chart. 
```
helm repo add collabora https://collaboraonline.github.io/online/
helm install --create-namespace --namespace collabora collabora-online collabora/collabora-online -f values.yaml
```
