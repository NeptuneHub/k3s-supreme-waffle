#!/bin/bash
#
# Generate the timestamp
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Echo the header with the timestamp
echo "******************************************************************************************"
echo "$TIMESTAMP"
echo "******************************************************************************************"
echo   # Add a blank line for clarity or further content

# Define the list of URLs to check
urls=(
    "http://ubuntu2.silverycat.de/"
    "http://ubuntu3.silverycat.de/"
    "http://ubuntu4.silverycat.de/"
)

# Function to check all URLs
check_urls() {
    for url in "${urls[@]}"; do
        echo "Checking $url..."
        response=$(curl -s -w "%{http_code}" --max-time 10 "$url")
        http_status="${response: -3}"
        echo "HTTP status code for $url: $http_status"

        # If the status code indicates an error (000, 4xx, or 5xx), return failure
        if [[ "$http_status" == "000" || "$http_status" =~ ^[45] ]]; then
            echo "Error detected for $url with status $http_status."
            return 1
        fi
    done
    return 0
}

# Initial check of all URLs
if ! check_urls; then
    echo "Errors detected in initial check. Restarting remote machine (116.203.31.211)..."

    # Reboot the remote machine via SSH (no terminal required)
    ssh -o ConnectTimeout=5 root@<IP-OF-VM-WITH-PUBLIC-IP> "nohup reboot -h now &"

    # Wait for 1 minute (60 seconds) for the remote machine to reboot
    sleep 60

    # Restart the local autossh-tunnel.service
    echo "Restarting autossh-tunnel.service locally..."
    sudo systemctl restart autossh-tunnel.service

else
    echo "All URLs are OK. No action required."
fi
