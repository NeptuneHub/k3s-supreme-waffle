#!/bin/bash

# Define the source and destination directories
SOURCE_DIR="/var/lib/rancher/k3s"
DEST_DIR="/mnt/usb-2/k3s_backup"

# Check if the source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
  echo "Source directory $SOURCE_DIR does not exist. Exiting."
  exit 1
fi

# Create the destination directory if it does not exist
if [ ! -d "$DEST_DIR" ]; then
  mkdir -p "$DEST_DIR"
fi

# Perform the copy operation maintaining permissions and ownership
rsync -avz --delete --chown --preserve-permissions "$SOURCE_DIR/" "$DEST_DIR/"

# Check if the copy was successful
if [ $? -eq 0 ]; then
  echo "K3S files successfully copied to $DEST_DIR."
else
  echo "Failed to copy K3S files. Check the output for errors."
  exit 1
fi
