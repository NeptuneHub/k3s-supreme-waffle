# K3s Insecure Private Container Registry Setup

This README outlines the configuration steps for deploying an **insecure** private Docker container registry within a K3s cluster. This setup is **NOT suitable for production environments** due to the lack of authentication and HTTPS, making it vulnerable to unauthorized access and data interception. It is intended for isolated development and testing purposes only.

---

## Table of Contents

1.  [Security Warning](#1-security-warning)
2.  [Private Registry Deployment on K3s](#2-private-registry-deployment-on-k3s)
    * [Registry Deployment YAML (`registry-deployment.yaml`)](#registry-deployment-yaml-registry-deploymentyaml)
    * [Deployment Steps](#deployment-steps)
3.  [K3s Node Configuration (for Image Pulls)](#3-k3s-node-configuration-for-image-pulls)
    * [Configuration File (`/etc/rancher/k3s/registries.yaml`)](#configuration-file-etcrancherk3sregistriesyaml)
    * [Restart K3s Service](#restart-k3s-service)
4.  [Local Docker Client Configuration (for Pushing/Pulling)](#4-local-docker-client-configuration-for-pushingpulling)
    * [Configuration File (`/etc/docker/daemon.json`)](#configuration-file-etcdockerdaemonjson)
    * [Restart Docker Daemon](#restart-docker-daemon-1)
5.  [Image Management Workflow](#5-image-management-workflow)
    * [Build Docker Image](#build-docker-image)
    * [Push Image to Private Registry](#push-image-to-private-registry)
    * [Verify Image in Registry](#verify-image-in-registry)
6.  [Deploying an Application on K3s using the Private Registry](#6-deploying-an-application-on-k3s-using-the-private-registry)
    * [Application Deployment YAML (`my-app-deployment.yaml`)](#application-deployment-yaml-my-app-deploymentyaml)
    * [Deployment Steps](#deployment-steps-1)
    * [Accessing the Application](#accessing-the-application)

---

## 1. Security Warning

**THIS SETUP IS INSECURE!**

* **No Authentication:** Anyone who can reach your registry's IP and port (e.g., `192.168.3.16:5000`) can push, pull, or delete any image without credentials.
* **No HTTPS/TLS:** All communication with the registry is unencrypted (HTTP). This means image data and any future credentials (if added) could be intercepted.

**Only use this configuration for isolated development or testing environments where security is not a concern.** For production, implement HTTPS with valid certificates and robust authentication.

---

## 2. Private Registry Deployment on K3s

This section describes the Kubernetes manifests to deploy the `registry:2` container.

**Registry IP and Port:** `192.168.3.16:5000` (Assumed LoadBalancer IP and default registry port)
**Node for HostPath:** `unbutu3` (Pod will be scheduled on this node)
**Namespace:** `registry`

### Registry Deployment YAML (`registry-deployment.yaml`)

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
