# Introduction
Authentik is an additional security layer that you can add to your K3S cluster that also work on ARM processor (Raspberry PI 5). It can be use for multiple use case but in this guide the final golas will be provide a centralized Authentication and Authorization page for all our app. This means that even application with no login page will be redirected here and all the user will be store in the Authentik DB.


# Deploy with helm chart

First step download the values.yaml in this repo, you need to edit:
* <replace-secure-password-1-here> and <replace-secure-password-1-here>, you can randomly generate with this command openssl rand 60 | base64 -w 0
* the host entrypoint that in my case is auth.silverycat.de
* the cert manager cluster issuer that in my case is letsencrypt-production

Then you can install with helm by this command

```
helm repo add authentik https://charts.goauthentik.io
helm repo update
helm upgrade --install authentik authentik/authentik -f values.yaml --namespace authentik --create-namespace
```

After that you need to finish the configuration going to this url:
```
https://auth.silverycat.de/if/flow/initial-setup/
```
# Add an application (readarr in this example)
Now from the web interface you need to create your new APP that in our case is readarr so:
* Login to the admin webpage, in our case https://auth.silverycat.de/if/admin/
* Go in the menu applications > application > Create with wizard
* Input the name, in our case readarr then click next
* For the provider select forward auth single application and then enxt
* Select the default authorization flow AND input the URL of your service, in our case is http://radarr.192.168.3.120.nip.io
* Now you need to go to applications > outposts and click edit on the authentik Embedded Outpost (that sould be automatically create)
* Put readarr in the application selected and create update

So now you configured the new application, but what is missing is creating middleware and ingress-route that need to made a forward-auth to authentik outpost. So this means that everytime you input the url, your are automatically forwarded to the auth page.

First deploy the middleware and the ingressroute for readarr you can use middleware.yaml (in this example we assume readarr is deployed in namespace servarr):
```
kubectl apply -f middleware.yaml
```

In the above file all the middleware are re-usable for additional app. Instead you need to create a new ingressroute for each new service.


Then you need to create the ingressroute for the outpost, this one is reusable even for new service:
```
kubectl apply -f ingressroute.yaml
```

At the moment you still have a configuration left about traefik on KRS that don't allow ingressroute in different namespace from the service. You can use the traefik helm chart config in this repo and apply with:

```
kubectl apply -f traefik-helmchartconfig.yaml
```





# References
* **Authentik official documentation for installation** - https://docs.goauthentik.io/docs/installation/kubernetes
