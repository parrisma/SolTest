#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
  echo "This script must be run as root or by sudo"
  exit 1
fi

if [ -z "$2" ]; then
    echo "Usage: $0 <username> <target directory>"
    exit 1
fi

target_user="$1"
target_dir="$2"
group_name="rust-dev"
group_id=1678

if ! getent group "$group_name" >/dev/null; then
  sudo groupadd --gid "$group_id" "$group_name"
  if [ $? -eq 0 ]; then
    echo "Successfully created group [$group_name] with GID [$group_id]"
  else
    echo "Failed to create group [$group_name]"
    exit 1
  fi
else
  echo "Group [$group_name] already exists"
fi

# Add the current user to the group if they are not already a member
if ! id -G "$target_user" | grep -q "\b$group_id\b"; then
  sudo usermod -aG "$group_name" "$target_user"
  if [ $? -eq 0 ]; then
    echo "Successfully added user [$target_user] to group [$group_name]"
  else
    echo "Failed to add user [$target_user] to group [$group_name]"
    exit 1
  fi
else
  echo "User [$target_user] is already a member of group [$group_name]"
fi

# Set group ownership and permissions recursively
if [ -d "$target_dir" ]; then
  sudo chgrp -R "$group_name" "$target_dir"
  sudo chmod -R g+rw "$target_dir"
  echo "Successfully set group ownership to [$group_name] and added read/write permissions for group to [$target_dir] and all subdirectories/files"
else
  echo "Error: [$target_dir] is not a valid directory"
  exit 1
fi

