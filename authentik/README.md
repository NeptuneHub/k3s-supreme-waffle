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



References:
* **Authentik official documentation for installation** - https://docs.goauthentik.io/docs/installation/kubernetes
