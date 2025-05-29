# K3s Insecure Private Container Registry Setup
This is to deploy a private container registry on your local k3s cluster for development. In this setup we will not use password or other protection (like https) supposing it will run only on you lan.

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

To deploy the registry you can simply deploy this yaml:

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
