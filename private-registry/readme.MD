# K3s Insecure Private Container Registry Setup
This is to deploy a private container registry on your local k3s cluster for development. In this setup we will not use password or other protection (like https) supposing it will run only on you lan for development purpose.
Potentially you can configure a password but then need to be used for both pull and push.

## Allow K3S node to use insecure registry

To use insecure registry on K£S you need to edit or create this on each node:

```
vim /etc/rancher/k3s/registries.yaml on each node
```

and add this, remembering to use your registry ip and port:
```
# /etc/rancher/k3s/registries.yaml
mirrors:
  "192.168.3.16:5000": # The name of your registry
    endpoint:
      - "http://192.168.3.16:5000" # Explicitly use HTTP
configs:
  "192.168.3.16:5000":
    tls:
      insecure_skip_verify: true # Crucial for insecure HTTP registries
```

after that you need to restart k3s on the node, if it's a server node:

```
sudo systemctl restart k3s
```

## Deploy the registry

To deploy the registry you can simply deploy this yaml, but remember to change namespace, node selector, port and eventually ip:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: registry
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: private-registry
  namespace: registry # Specified namespace
  labels:
    app: private-registry
spec:
  replicas: 1
  selector:
    matchLabels:
      app: private-registry
  template:
    metadata:
      labels:
        app: private-registry
    spec:
      nodeSelector:
        kubernetes.io/hostname: unbutu3 # Ensures deployment on this specific node
      volumes:
        - name: registry-data
          hostPath:
            path: /mnt/registry # Persistent storage on the host node
            type: DirectoryOrCreate
      containers:
        - name: registry
          image: registry:2
          ports:
            - containerPort: 5000
          volumeMounts:
            - name: registry-data
              mountPath: /var/lib/registry
          securityContext:
            runAsUser: 0     # Set the user ID inside the container to root
            runAsGroup: 0    # Set the group ID inside the container to root
            allowPrivilegeEscalation: true
---
apiVersion: v1
kind: Service
metadata:
  name: private-registry
  namespace: registry # Specified namespace
  labels:
    app: private-registry
spec:
  selector:
    app: private-registry
  ports:
    - protocol: TCP
      port: 5000
      targetPort: 5000
  type: LoadBalancer # Exposes the registry via an external IP (requires LoadBalancer provider like MetalLB)
  # Uncomment if you want to assign a a specific IP from your MetalLB pool:
  # loadBalancerIP: 192.168.3.16
```

## Use the registry

On the local machine where you have docker installed and you want to build and push the container you need to:

```
sudo vim /etc/docker/daemon.json
```

and add this (change ip and port with your registry):
```
{
  "insecure-registries": [
    "192.168.3.99:5000"
  ]
}
```

Now that you have your registry you can build and push a container image in your localhost with this command:
```
docker build -t 192.168.3.99:5000/audiomuse-ai:local .
docker push 192.168.3.99:5000/audiomuse-ai:local
```
Just edit name and tag of your container.

You will find your registry catalog here:
* http://192.168.3.16:5000/v2/_catalog

and the tag list here:
* http://192.168.3.16:5000/v2/audiomuse-ai/tags/list

Finaly to deploy your container you should put in your deployment something like this:
```
image: 192.168.3.16:5000/audiomuse-ai:local
```
