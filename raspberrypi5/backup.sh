#!/bin/sh

# Echo the header with the timestamp
echo "******************************************************************************************"
echo "$TIMESTAMP"
echo "******************************************************************************************"
echo   # Add a blank line for clarity or further content

# Define destination base directory
dest_base="/mnt/usb"

# Function to get PVC name dynamically
get_pvc_name() {
  # Run kubectl command to get PVC name in the nextcloud namespace
  volume_name=$(kubectl get pvc nextcloud-server-pvc -n nextcloud -o=jsonpath='{.spec.volumeName}')

  # Concatenate the desired suffix
  result="${volume_name}_nextcloud_nextcloud-server-pvc"

  # Output the final result
  echo "$result"
}

# Get the PVC name
pvc_name=$(get_pvc_name)

# Check if PVC name is empty or not found
if [ -z "$pvc_name" ]; then
  echo "Error: No PVC found in nextcloud namespace."
  exit 1
fi

# Define source base directory dynamically using the obtained PVC name
source_base="/var/lib/rancher/k3s/storage/$pvc_name/data"

# Perform rsync for each source and destination pair
echo "Rsync from $source_base/admin/files/ to $dest_base/admin"
rsync -av "$source_base/admin/files/" "$dest_base/admin"
