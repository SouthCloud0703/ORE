FROM rust:slim-bullseye

# Install dependencies
RUN apt-get update && \
    apt-get install -y openssl pkg-config libssl-dev build-essential make bc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install ore-cli
RUN cargo install ore-cli

# Create directory for wallet keys
RUN mkdir -p /root/.config/solana

# Create a script to manage mining and claiming
RUN echo '#!/bin/bash\n\
\n\
# Get the wallet address from the keypair file\n\
WALLET_ADDRESS=$(solana address)\n\
echo "Using wallet address for mining and rewards: $WALLET_ADDRESS"\n\
\n\
# Start mining in the background\n\
ore mine &\n\
MINING_PID=$!\n\
\n\
# Function to handle exit\n\
function cleanup() {\n\
    echo "Stopping mining process..."\n\
    kill $MINING_PID\n\
    exit 0\n\
}\n\
\n\
# Set up trap\n\
trap cleanup SIGTERM SIGINT\n\
\n\
# Check and claim rewards periodically\n\
while true; do\n\
    # Sleep for 1 hour before checking rewards\n\
    sleep 3600\n\
    \n\
    # Check current balance\n\
    BALANCE=$(ore account | grep "Balance" | awk "{print \\$2}")\n\
    \n\
    # If balance exists, claim it to the same wallet\n\
    if [ ! -z "$BALANCE" ] && [ "$BALANCE" != "0" ]; then\n\
        echo "Claiming $BALANCE ORE to $WALLET_ADDRESS..."\n\
        ore claim all --to $WALLET_ADDRESS\n\
        echo "Claim completed at $(date)"\n\
    else\n\
        echo "No claimable balance found at $(date)"\n\
    fi\n\
done\n\
' > /usr/local/bin/mine-and-claim.sh && chmod +x /usr/local/bin/mine-and-claim.sh

# Set entrypoint to our new script
ENTRYPOINT ["/usr/local/bin/mine-and-claim.sh"]

# Use a healthcheck to verify the miner is still running
HEALTHCHECK --interval=5m --timeout=3s \
  CMD ps aux | grep -q "[o]re mine" || exit 1
