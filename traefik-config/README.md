# Introduction
Goals of this how-to is show how to configure IP and Bandwidht limit on an already deployed Traefik. In this case we are configuring the one included in K3S.

# traefik-config.yaml
First point is addind this `HelmChartConfig` in `/var/lib/rancher/k3s/server/manifests` and apply it:

```
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  # The name must match the Helm release name, which is 'traefik' for K3s
  name: traefik
  namespace: kube-system
spec:
  # This is where you put your custom values, just like in a values.yaml file
  valuesContent: |-
    service:
      spec:
        externalTrafficPolicy: Local
    # --- BANDWIDTH PLUGIN ---
    experimental:
      plugins:
        bandwidthlimiter:
          moduleName: github.com/hhftechnology/bandwidthlimiter
          version: v1.0.0
```

The two main important information will be:
* externalTrafficPolicy: Local   => needed to receive the real ip of the cluster
* github.com/hhftechnology/bandwidthlimiter => that is the plugin that add the ability to limit the bandwidth

# middleware-band.yaml 
This is the middleware that use the bandwidth plugin.
```
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: global-bandwidth-cap
  namespace: pocketbase # Use the same namespace as your Pocketbase Ingress
spec:
  plugin:
    bandwidthlimiter:
      # Limit the total outgoing bandwidth to 7.7 Megabyte per second
      defaultLimit: 8074035
      # Allow an initial burst of 40 Megabytes
      burstSize: 41943040
```


# middleware.yaml
This middleware limit per user the number of call that can do per minute. Using the `sourceCriterion` in that way enable to read the real client IP.

```
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: pocketbase-api-ratelimit
  namespace: pocketbase # Make sure this matches the namespace of your Pocketbase service
spec:
  rateLimit:
    average: 120
    period: "1m"
    burst: 120

    # This ensures the limit is applied per unique client IP address.
    sourceCriterion: {}
```

# ingress-route.yaml
Finally the ingressroute that use the above middlewares.

```
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: pocketbase-ingressroute
  namespace: pocketbase
  annotations:
    cert-manager.io-cluster-issuer: "letsencrypt-production"
    acme.cert-manager.io/http01-edit-in-place: "true"
spec:
  entryPoints:
    - websecure
  routes:
    - match: Host(`YOUR.DOMAIN.de`)
      kind: Rule
      services:
        - name: pocketbase-service
          port: 8090
      middlewares:
        - name: pocketbase-api-ratelimit
          namespace: pocketbase
        - name: global-bandwidth-cap
          namespace: pocketbase
  tls:
    secretName: pkb-silverycat-de-tls
```

In this example the ingressroute is for pocketbase.
