# Expose Jellyfin via Tailscale VPN on K3s Cluster

This guide shows how to securely expose your Jellyfin instance running on a K3s cluster to the internet using Tailscale VPN. This creates a private, encrypted connection that only devices authenticated to your Tailscale network can access.

## Prerequisites

- K3s cluster with Jellyfin deployed
- Traefik configured as ingress controller
- Existing Jellyfin IngressRoute working locally
- Root access to the K3s node you want to expose

## Step 1: Install Tailscale

SSH into your K3s node (e.g., ubuntu2 with IP 192.168.3.131):

```bash
# Download and install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Start Tailscale and authenticate
sudo tailscale up
```

Follow the authentication URL in your browser and log in to your Tailscale account.

## Step 2: Verify Tailscale Installation

```bash
# Check Tailscale status
tailscale status

# Get your Tailscale IP (note it down)
tailscale ip -4
```

Expected output:
```
100.91.xxx.xx   ubuntu2              yourname@domain.com linux   -
```

## Step 3: Create Tailscale IngressRoute

Create a new IngressRoute specifically for Tailscale access:

```bash
nano jellyfin-tailscale-ingressroute.yaml
```

Replace `100.91.xxx.xx` with your actual Tailscale IP from Step 2:

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: jellyfin-tailscale-ingressroute
  namespace: servarr  # Replace with your namespace
spec:
  entryPoints:
  - taliscaleweb  # Replace with your entrypoint
  routes:
  - kind: Rule
    match: Host(`100.91.xxx.xx`)  # Your Tailscale IP
    services:
    - name: jellyfin  # Your Jellyfin service name
      port: 80
    middlewares:
    - name: cors  # Replace with your middleware if different
      namespace: authentik-ha  # Replace with your middleware namespace
    priority: 100  # High priority to avoid conflicts
```

Apply the IngressRoute:

```bash
kubectl apply -f jellyfin-tailscale-ingressroute.yaml
```

Verify creation:
```bash
kubectl get ingressroute -n servarr
```

## Step 4: Configure Tailscale Serve

Expose port 8086 (or your custom entrypoint port) via Tailscale:

```bash
sudo tailscale serve --bg 8086
```

Verify the serve configuration:
```bash
sudo tailscale serve status
```

## Step 5: Test Local Access

Test that everything works from the K3s node:

```bash
# Test local access
curl -I http://localhost:8086

# Test via Tailscale IP
curl -I http://100.91.xxx.xx:8086
```

You should receive HTTP 200 or 302 responses (not connection refused).

## Step 6: Create Auto-Start Service

Create a systemd service to automatically start Tailscale serve after reboots:

```bash
sudo nano /etc/systemd/system/tailscale-jellyfin.service
```

Add this content:

```ini
[Unit]
Description=Tailscale Serve for Jellyfin
After=tailscaled.service
Wants=tailscaled.service

[Service]
Type=oneshot
ExecStart=/usr/bin/tailscale serve --bg 8086
RemainAfterExit=yes
User=root

[Install]
WantedBy=multi-user.target
```

Enable and start the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable tailscale-jellyfin.service
sudo systemctl start tailscale-jellyfin.service
```

Verify the service:
```bash
sudo systemctl status tailscale-jellyfin.service
```

## Step 7: Install Tailscale on Client Devices

Install Tailscale on devices you want to access Jellyfin from:

- **Windows/Mac/Linux**: Download from https://tailscale.com/download
- **iOS/Android**: Install Tailscale app from app store
- **Other Linux machines**: Use the same curl command as Step 1

Authenticate each device with your Tailscale account.

## Step 8: Access Jellyfin

From any device connected to your Tailscale network, access Jellyfin using:

```
http://100.91.xxx.xx:8086
```

Replace `100.91.xxx.xx` with your actual Tailscale IP.

## Step 9: Test Reboot Persistence

Verify everything survives a reboot:

```bash
# Reboot the K3s node
sudo reboot

# After reboot, verify services
tailscale status
sudo tailscale serve status
sudo systemctl status tailscale-jellyfin.service

# Test access again
curl -I http://100.91.xxx.xx:8086
```

## Troubleshooting

### Check IngressRoutes
```bash
kubectl get ingressroute -n servarr
kubectl describe ingressroute jellyfin-tailscale-ingressroute -n servarr
```

### Check Tailscale
```bash
tailscale status
sudo tailscale serve status
```

### Check SystemD Service
```bash
sudo systemctl status tailscale-jellyfin.service
sudo journalctl -u tailscale-jellyfin.service -f
```

### Check Port Listening
```bash
sudo netstat -tlnp | grep :8086
```

### Check Traefik Logs
```bash
kubectl logs -n kube-system -l app.kubernetes.io/name=traefik --tail=20 -f
```

### Common Issues

1. **Getting Grafana instead of Jellyfin**: Check IngressRoute priority and matching rules
2. **Connection refused**: Verify Tailscale serve is running and port is correct
3. **404 errors**: Check service name and port in IngressRoute
4. **After reboot not working**: Check if systemd service is enabled and running

## Security Notes

- Only devices authenticated to your Tailscale network can access Jellyfin
- Traffic is encrypted end-to-end
- No ports need to be opened on your firewall
- Consider enabling Jellyfin's built-in authentication for additional security
- Regularly update both Tailscale and Jellyfin

## Optional: Uninstall Guide

### Remove Tailscale Serve Configuration

```bash
# Stop the systemd service
sudo systemctl stop tailscale-jellyfin.service
sudo systemctl disable tailscale-jellyfin.service

# Remove the service file
sudo rm /etc/systemd/system/tailscale-jellyfin.service
sudo systemctl daemon-reload

# Reset Tailscale serve configuration
sudo tailscale serve reset
```

### Remove Tailscale IngressRoute

```bash
# Delete the IngressRoute
kubectl delete ingressroute jellyfin-tailscale-ingressroute -n servarr

# Remove the YAML file
rm jellyfin-tailscale-ingressroute.yaml
```

### Remove Tailscale (Optional)

```bash
# Stop Tailscale
sudo tailscale down

# Remove from Tailscale admin console
# Go to https://login.tailscale.com/admin/machines
# Find your machine and click "Delete"

# Uninstall Tailscale (Ubuntu/Debian)
sudo apt remove tailscale
sudo rm -rf /var/lib/tailscale
```

### Clean up Authentication

- Remove the machine from your Tailscale admin console
- Revoke any auth keys if you used them
- Remove Tailscale apps from client devices if no longer needed

## Notes

- Replace all placeholder values (IPs, namespaces, service names) with your actual configuration
- The Tailscale IP address might change if you remove and re-add the machine
- Keep your Tailscale client apps updated for security
- Consider using Tailscale ACLs for additional access control in larger deployments
