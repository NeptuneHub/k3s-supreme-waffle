# Introduction
Authentik is an additional security layer that you can add to your K3S cluster that also work on ARM processor (Raspberry PI 5). It can be use for multiple use case but in this guide the final golas will be provide a centralized Authentication and Authorization page for all our app. This means that even application with no login page will be redirected here and all the user will be store in the Authentik DB.

If you have K3S 3 node cluster in HA, you can follow the HA guide in this repo **./ha**


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

After that go to the main page:
```
https://auth.silverycat.de/
```

And then ad the kubernetes integration:
```
System > Outpost integration > create > Kubernetes Service-Connection
Put as a name "local"
and also cut&pate your :~/.kube/config
```

Also add the outpost to use the new local one:
```
application > outpost > create
as a name put: authentik-embedded-outpost
as integration put: local
```


# Add an application as a proxy (readarr in this example)
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

# Configure Oauth SSO (jellyfin in this example)

In this exampple we want to integrate jellyfin with Authentik using Oauth SSO.
First point you need to follow the "proxy" chapter but to expose Jellyfin so you will add a first application&provider as a proxy.

Second you need to add a second couple of Application&Providere for Oauth in the web page of authentik. So first add the provider (in my case the url of jellyfin is jellyfin.192.168.3.120.nip.io, you can edit it):
```
Type: Oauth2/Openid provider
name: Jellyfin2 (becasue jellyfin already used for the proxy provider
authorization flow: implicit
client type: confidential
redirect uri: https://jellyfin.192.168.3.120.nip.io/sso/OID/redirect/authentik
```
Rember to write down **client id** and **client secret**.

Then create a new application

```
name: Jellyfin2
provider: Jellyfin2 (created before)
ui setting > launch url: https://jellyfin.192.168.3.120.nip.io/sso/OID/start/authentik
```

In this case you don't need to touch nothing in the outpost and now you can go on Jellyfin, where under menu > control panel > plugin > repository you need to add this:

* https://raw.githubusercontent.com/9p4/jellyfin-plugin-sso/manifest-release/manifest.json

then you need to install the new SSO-auth plugin. After the installation you need to confgiure it in this way:
```
name of oid provider: authentik
oid endpoint: https://auth.silverycat.de/application/o/jellyfin/.well-known/openid-configuration
openid cliend id/secret: the one that you created with the provider
enabled: checked
enabled authorization plugin: checked
enabled all folder: checked (or decide what do you want to enable
```

The last step is to add the "sso button" in the login page of Jellyfin. To do that go in the menu General > branding and under login disclaimer add this:
```
<form action="https://jellyfin.192.168.3.120.nip.io/sso/OID/start/authentik">
  <button class="raised block emby-button button-submit">
    Sign in with SSO
  </button>
</form>
```

under css add this:
```
a.raised.emby-button {
    padding:0.9em 1em;
    color: inherit !important;
}

.disclaimerContainer{
    display: block;
}
```

**important**
* In all this snippet remember to change https://jellyfin.192.168.3.120.nip.io => with the actual url.
* Use HTTPS for jellyfin
* Remember to have a valid certificate for Authentik (like one free that you can get with cert-manager + letsencrypt) otherwisw you will have error during the SSO proces
* Remember that you can look the log about Jellyfin in the webapp > menu > logs. Some SSO error can be look there
* Remember also that let's encrypt need the port 80 open for acquire a new TLS certificate. So even if your service is on 443, you need yo be reachable from port 80.

# Configure LDAP integration (Jellyfin in this example)

First you need to go to the authentik web page and create a bind usre:
```
Go to directory > user and click on create service account (remember to save the token created as a password and to create a group => in our case we named both user and group ldap
```

Now create the provider:
```
go to application > providers > creates > ldap
Search Group: ldap
Bind and Search Mode: Cached
Base DN: DC=ldap,DC=silverycat,DC=de
```

Create an application to assign to the provided
```
go to application > application
name: jellyfin-ldap
Launch URL: http://jellyfin.192.168.3.120.nip.io
```

Create the LDAP outpost
```
Go to applications > outposts > create
Type: LDAP
Integration: <add docker or kubernetes if available>
Application: jellyfin-ldap
```

Checking in namespace authentik you now should have the svc related to the outpost so **ak-outpost-ldap**

Now go to jellyfin with you admin account and go to **menu > control panel > plugin** and install the plugin  **LDAP Authentication Plugin**.

Then you need to configure it in this way:
```
ldap server: ak-outpost-ldap.authentik.svc.cluster.local
ldap port: 636
secure ldap: checked
skip SSL/TLS verification: checked if you are using a self signed certificate
LDAP Bind user:  cn=ldap,dc=ldap,dc=silverycat,dc=de
LDAP Bind user password: put the token of the user LDAP that you created
LDAP base DN for searches: dc=ldap,dc=silverycat,dc=de
=> save an test ldap server setting should give you: Connect (Success); Bind (Success); Base Search (Found XX Entities)

ldap search filter: (objectClass=user)
ldap search attributes: uid, cn, mail, displayName
LDAP Uid attribute: uid
LDAP username attribute: cn
LDAP Password attribute: userPassword
(here we skipped the configuration of admin user)
=> save and test LDAP filter settings should give you: Found X user(s), 0 admin(s)
enalbe user creation: checked
Lbrary access: checked.
=> save
```

After this you can log-out and login with any user that you create under authentik.
**IMPORTANT:** if you already have a user in jellyfin with the same name of an user on Authentik, this will create problem, so I suggest to start with only the admin user on jellyfin.

# References
* **Authentik official documentation for installation** - https://docs.goauthentik.io/docs/installation/kubernetes
* **Authentik official DOC jellyfin integration** - https://docs.goauthentik.io/integrations/services/jellyfin/
* **Jellyfin Oauth plugin** - https://github.com/9p4/jellyfin-plugin-sso
* **Jellyfin Oauth plugin on reddit** -  https://www.reddit.com/r/selfhosted/comments/x2vey3/authentik_to_jellyfin_plugin_sso_setup/
* **Jellyfin ldap plugin on reddit** - https://www.reddit.com/r/selfhosted/comments/x3b74z/authentik_ldap_with_jellyfin_setup/?share_id=XBw8GWdG9an9o3AQPxZmN&utm_content=1&utm_medium=android_app&utm_name=androidcss&utm_source=share&utm_term=10
