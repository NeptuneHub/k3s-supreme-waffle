# Introduction
This how to is to install Synapse home server for Matrix AND element as a web chat on your homelab. This will be used also send and receive notification from the homelab server (like from uptime kuma).

# Install
The installation is with helm by using this commands **values.yaml**, remeber to change:

* All the server name and base url
* the cluster issuer name for the https certificate
* **enable_registration** and **enable_registration_without_verification** are initially to false to avoid registration . You can enable to create your used and then disable.

Then just proceed with the installation by running this commands:
```
helm repo add matrix https://remram44.github.io/matrix-helm
kubectl create namespace chat
helm install chat matrix/matrix --namespace chat -f values.yaml
```

# Send message by cli

A message can be send by the command line with something like this:
```
curl -X POST https://chat.yourserver.de/_matrix/client/r0/rooms/\<your-chat-room>/send/m.room.message \
-H "Authorization: Bearer <your-user-token> \
-H "Content-Type: application/json" \
-d '{
  "msgtype": "m.text",
  "body": "Hello, this is a test message!"
}'
```
where you need to edit:
* https://chat.yourserver.de with your server url
* <your-chat-room> with your room id, something like !xxxxxxxxxxxxxx:chat.yourserver.de, you can find it if you access by we in the url of the room
* <your-user-token> with the access token of your user, you can find it click on your username icon in the corner > privacy > help  and scrolling down to access token 
* body with your message
