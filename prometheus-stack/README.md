
This is to install the kube-prometheus-stack by using HELM chart. This could be helpful to have a **Grafana Dashboard fully configured with prometheus** to monitor your K3S cluster.

In this configuration we assume that you have **cert-manager configured** with your domain because you will access to the web dashboard (grafana) in https. If not colof the guide in ./cert-manager of this repo.

Fir step download values.yaml on your local cluster end remember to edit under grafana the ingress / tls configuration with yout domain. Actually are configured in this way:

```
  ingress:
    enabled: true
    className: traefik

    ## Annotations for Grafana Ingress
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-production
    labels: {}
    hosts: []
    path: /
    tls:
      - secretName: dash-silverycat-de-tls
        hosts:
          - dash.silverycat.de
```

Then you can create the namespace:
```
kubectl create namespace dash
```

add the helm charts:
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

and finally proceed with the installaon that will take a bit (so just wait if seems it get stuck):
```
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -f values.yaml --namespace dash
```

now you can access via web to the grafana dashboard. The initial user is **admin** and to get the main password you can run this command (supposing you used the namespace dash like me):
```
kubectl get secret -n dash kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```




**References**
* **Kube-prometheus-stack github** - https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack
