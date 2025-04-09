#!/bin/bash

solana config set --url localhost

solana config set --keypair kiboMMPZE3xfxShLEeg5Y5r46PN5yPu2dygfdQuFt5h.json

start_local_validator=false

# Parse command-line flags
while getopts "l" opt; do
  case $opt in
    l)
      start_local_validator=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

check_balance() {
  if pgrep -f "solana-test-validator" > /dev/null; then
    # Check balance using Solana CLI
    BALANCE=$(solana balance --output json | jq -r '.lamports')

    # Define threshold
    THRESHOLD=10

    # Print current balance
    echo "Current SOL balance: $BALANCE"

    # Get Solana balance using Solana CLI
    BALANCE=$(solana balance --output json | jq -r '.lamports')
    BAL=$(echo "$BALANCE / 1000000000" | bc -l) # Convert lamports to SOL

    # Define the threshold
    THRESHOLD=10

    # Display the current balance
    echo "Current Solana balance: $BAL SOL"

    # Check if the balance is greater than the threshold
    if (( $(echo "$BAL > $THRESHOLD" | bc -l) )); then
      echo "Balance is greater than $THRESHOLD SOL."
    else
      echo "Balance is below $THRESHOLD SOL. Requesting airdrop..."
  
      # Request airdrop (1 SOL as an example, adjust if needed)
      solana airdrop 3
  
      # Confirm airdrop request
      echo "Airdrop requested."
    fi
  else
    echo "Validator is not running. Skipping balance check."
  fi  
}

# Function to check if the validator is running
check_validator() {
  if pgrep -f "solana-test-validator" > /dev/null; then
    echo "Validator is already running, stopping..."
    pkill -f "solana-test-validator"
    echo "Validator stopped."
  fi
  
  echo "Starting the validator..."
  solana-test-validator --reset&
  echo "Validator started."
  return 1
}

if [ "$start_local_validator" = true ]; then
  # Ensure a local validator is running
  check_validator

  # Wait a moment to ensure the validator starts properly
  sleep 10

else
  echo "Not starting a local validator. Skipping balance check."
fi

# Check Solance balance is sufficient
check_balance
