FROM rust:slim-bullseye

# Install dependencies
RUN apt-get update && \
    apt-get install -y openssl pkg-config libssl-dev build-essential make && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install ore-cli
RUN cargo install ore-cli

# Create directory for wallet keys
RUN mkdir -p /root/.config/solana

# Copy your keypair file (you'll need to have this file in the build context)
# COPY id.json /root/.config/solana/id.json

# Set entrypoint to start mining
ENTRYPOINT ["ore", "mine"]

# Use a healthcheck to verify the miner is still running
HEALTHCHECK --interval=5m --timeout=3s \
  CMD ps aux | grep -q "[o]re mine" || exit 1
