#!/bin/bash
#replace the engine name with the correct one of your installation
kubectl rollout restart daemonset engine-image-ei-b0369a5d -n longhorn-system
kubectl rollout restart daemonset longhorn-csi-plugin -n longhorn-system
kubectl rollout restart daemonset longhorn-manager -n longhorn-system

kubectl rollout restart deploy csi-attacher -n longhorn-system
kubectl rollout restart deploy csi-provisioner -n longhorn-sytem
kubectl rollout restart deploy csi-resizer -n longhorn-system
kubectl rollout restart deploy csi-snapshotter -n longhorn-system
kubectl rollout restart deploy longhorn-driver-deployer -n longhorn-system
kubectl rollout restart deploy longhorn-ui -n longhorn-system
