# Introduction

**THIS IS UNDER CONSTRUCTION**

# Install and configuration on server

On the server site you need first to install wireguard

```
sudo apt update && sudo apt upgrade -y
sudo apt install wireguard -y
```

Then you need to generate the key
```
wg genkey | tee server_private.key | wg pubkey > server_public.key
```

Then you can proceed in creating the configuration file

```
sudo vim /etc/wireguard/wg0.conf
```

With configuration like this

```
[Interface]
Address = 10.0.0.3/24
SaveConfig = true
ListenPort = 51820
PrivateKey = xxxxxxx # Server private key

[Peer]
PublicKey = yyyyyyyy # Client1 pubblic key
AllowedIPs = 10.0.0.2/32 # IP address for the client1

[Peer]
PublicKey = pppppppp # Client2 pubblic key
AllowedIPs = 10.0.0.3/32 # IP address for the client2
```

Finally start the the vpn opn the server

```
sudo wg-quick up wg0
```

You can restart it, if needed (for example you change the configuration), with this command
```
sudo wg-quick down wg0
sudo wg-quick up wg0
```

# Install and configuration on client (windows/android)

Download the client
```
https://www.wireguard.com/install/
```
you can create the Public and private key of the client by
```
Click on Add Tunnel => Add Empty Tunnel.
```

In the empty tunnel you can now add the following information (PrivateKey should be laready created from the previous step):
```
[Interface]
PrivateKey = kkkkkkk # Client1 private key
Address = 10.0.0.2/32 #in case of Client2 remeber .3
DNS = 8.8.8.8

[Peer]
PublicKey = zzzzzzzzz # Server public key
AllowedIPs = 10.0.0.0/24 #you can use a subnet to use wireguard only for the subnet address, or use 0.0.0.0/0 for everything
Endpoint = serverIP:51820
PersistentKeepalive = 25
```
# Check
On server side to check if the connection configure is up just use this command:
```
sudo wg
```

# Enable wireguard on startup server
To enable wirguard at the startup on the server just run this command:
```
sudo systemctl enable wg-quick@wg0
```

