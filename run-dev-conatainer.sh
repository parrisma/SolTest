#!/bin/bash

force_rebuild=false

# Parse command-line flags
while getopts "f" opt; do
  case $opt in
    f)
      force_rebuild=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Check if the container is running
if docker ps --filter "name=rust-dev" --format "{{.ID}}" | grep -q .; then
  # Container is running, stop it
  echo "Stopping rust-dev container..."
  docker stop rust-dev

  # Remove the container
  echo "Removing rust-dev container..."
  docker rm rust-dev
  sleep 15
  echo "Removed rust-dev container..."
else
  echo "rust-dev container is not running."
fi

# Check if the image exists locally
if $force_rebuild || ! docker images -q rust-test:latest > /dev/null; then
  echo "Building rust-test:latest image..."
  docker build -t rust-test:latest .
  if [ $? -ne 0 ]; then
    echo "Failed to build rust-test:latest image."
    exit 1
  fi
else
  echo "rust-test:latest image found locally."
fi

# Remote vscode session as user rust-dev in group rust-dev needs local directory owned by rust dev and rwx for group
# so, on your dev machine as your user, run the following commands
# There is nothing special about Id 1678
# sudo groupadd -g 1678 rust-dev
# sudo usermod -aG rust-dev <user>
# sudo groupadd -g 1678 rust-dev

# Run the docker command with --rm and volume mount
docker run --rm --name rust-dev -d -v "$(pwd)":/home/rust-dev/devroot/rust --user 1678:1678 rust-test:latest tail -f /dev/null