#!/bin/sh
# Assign the first argument to dest_base
dest_base="<put-here-destination-of-your-backup>"

# Generate the timestamp
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Echo the header with the timestamp
echo "******************************************************************************************"
echo "Backup important"
echo "$TIMESTAMP"
echo "******************************************************************************************"
echo   # Add a blank line for clarity or further content

# Check if the destination directory exists
if [ ! -d "$dest_base" ]; then
    echo "Error: The directory '$dest_base' does not exist."
    exit 1
fi

# Check if any of the specified processes are running
if pgrep -x "rsync" || pgrep -x "restic"; then
    echo "Warning: script did not start because another backup is already running at: $(date)"
    exit 1
fi


# Check if any of the specified processes are running
if pgrep -x "rsync" || pgrep -x "restic"; then
    echo "Warning: script did not start because another backup is already running at: $(date)"
    exit 1
fi

# Check if the USB drive is mounted and writable
#IS_MOUNTED_AND_WRITABLE=$(mount | grep "$dest_base" | awk '{print $6}' | grep "rw")
IS_MOUNTED_AND_WRITABLE=$(mount | awk -v dest="$dest_base" '$3 == dest {print $6}' | grep "rw")

# Check the result and act accordingly
if [ -n "$IS_MOUNTED_AND_WRITABLE" ]; then
        echo "The USB drive at '$dest_base' is mounted and writable."
else
        echo "The USB drive at '$dest_base' is not mounted or not writable."
        # Attempt to unmount all filesystems (use with caution)
        echo "Attempting to unmount all filesystems..."
        sudo umount "$dest_base"
        # Remount all filesystems
        echo "Attempting to mount all filesystems..."
        sudo mount "$dest_base"
    # Check if the mount was successful
    if [ $? -eq 0 ]; then
        echo "Successfully mounted the USB drive at '$dest_base'."
    else
        echo "Failed to mount the USB drive at '$dest_base'. Aborting operation."
        exit 1
    fi
fi

# Define source base directory dynamically using the obtained PVC name
source_base="/var/lib/rancher/k3s/storage"

# Perform rsync for each source and destination pair
echo "Rsync from $source_base to $dest_base"
rsync -av "$source_base/" "$dest_base"
