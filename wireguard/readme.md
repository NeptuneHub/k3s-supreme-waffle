# Introduction


# Install and configuration on server

On the server site you need first to install wireguard

```
sudo apt update && sudo apt upgrade -y
sudo apt install wireguard -y
```

Then you need to generate the key
```
wg genkey | tee server_private.key | wg pubkey > server_public.key
wg genkey | tee client1_private.key | wg pubkey > client1_public.key
wg genkey | tee client2_private.key | wg pubkey > client2_public.key
```

Then you can proceed in creating the configuration file

```
sudo vim /etc/wireguard/wg0.conf
```

With configuration like this

```
[Interface]
PrivateKey = <server-private-key>
Address = 10.0.0.1/24       # VPN subnet
ListenPort = 51820          # Default WireGuard port
SaveConfig = true

[Peer]
PublicKey = <client-public-key>
AllowedIPs = 10.0.0.2/32    # IP address for the client
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
PrivateKey = <client-private-key>
Address = 10.0.0.2/32        # Client's VPN IP address
DNS = 8.8.8.8               # Optional, DNS server for the client

[Peer]
PublicKey = <server-public-key>
Endpoint = <server-ip>:51820 # Public IP of the server and port
AllowedIPs = 0.0.0.0/0       # All traffic routed through the VPN
PersistentKeepalive = 25     # Optional, helps keep the connection alive
```

