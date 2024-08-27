
# Introuduction
Neuvector is an application for security of your K3S cluster like scanning for CVE but also check the network policy.

# Install

First you need to connect in SSH to each node of your cluster and give this command, otherwise you can run in the error of "to many file opened" and newuvector dont' start
```
ulimit -n 65536
sudo sysctl fs.inotify.max_user_instances=1280
sudo sysctl fs.inotify.max_user_watches=655360
```

Then you can proceed with installing it with helm chart
```
helm repo add neuvector https://neuvector.github.io/neuvector-helm/
kubectl create namespace neuvector
kubectl label  namespace neuvector "pod-security.kubernetes.io/enforce=privileged"
helm install neuvector --namespace neuvector --create-namespace neuvector/core --values values.yaml
```

Finally you can get the url to reach it:
```
NODE_PORT=$(kubectl get --namespace neuvector -o jsonpath="{.spec.ports[0].nodePort}" services neuvector-service-webui)
NODE_IP=$(kubectl get nodes --namespace neuvector -o jsonpath="{.items[0].status.addresses[0].address}")
echo https://$NODE_IP:$NODE_PORT
```

Remember to change the password at your first login (user: admin password: admin)
