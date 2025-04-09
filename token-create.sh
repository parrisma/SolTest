#!/bin/bash

# Generate a new Solana keypair and store the path to the new keypair file
new_keypair_path=$(mktemp /tmp/solana_keypair.XXXXXX.json)
solana-keygen new --no-passphrase --force --outfile "$new_keypair_path"

# Check if keypair generation was successful
if [ $? -eq 0 ]; then
  echo "Generated new keypair at: $new_keypair_path"

  # Create the SPL token, using the newly generated keypair as the mint authority
  spl-token create-token \
    --decimals 6 \
    --enable-close \
    --enable-freeze \
    --enable-metadata \
    --enable-permanent-delegate \
    --url http://localhost:8899 \
    --program-id TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb \
    --mint-authority "$new_keypair_path" \
    --verbose \
    "$new_keypair_path"

  # Optional: Clean up the temporary keypair file after execution
  # rm "$new_keypair_path"
else
  echo "Error generating new Solana keypair."
fi