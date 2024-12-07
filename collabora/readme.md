# Introduction
This is to install Collabora online on K3S and then configure Nextcloud to integrate with it

# Install collabora

You can install collabora with the helm chart. You can use as an example the values.yaml here remembering to change:
* Host in the ingress, to fit your own domain
* Alias group, to fit the domain of your nextcloud (this is important or nextcloud will fail to connect it with a WOPI error)

After that just install it with this command:

```
helm repo add collabora https://collaboraonline.github.io/online/
helm install --create-namespace --namespace collabora collabora-online collabora/collabora-online -f values.yaml
```

# Configuring nextcloud

Now you need to install and enable in nextcloud admin web page the apps:
* Nextcloud Office
* Collabora Online - Built-in CODE Server

This is the connectors for collavbora online. Than in you admin page will appear the new link "office" where you need to select "use your server" and input your server url like https://collabora.silverycat.de.

# References
* **Collabora Online k8s documentation** - https://sdk.collaboraonline.com/docs/installation/Kubernetes.html#deploying-collabora-online-in-kubernetes
