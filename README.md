# Dockerized ORE Mining

This project automates ORE cryptocurrency mining using Docker containers for easy setup and management.

## Prerequisites

- Docker and Docker Compose
- A Solana keypair funded with SOL

## Setup Instructions

1. **Prepare your Solana keypair**

   If you don't have a Solana keypair, create one:
   ```bash
   solana-keygen new --outfile id.json
   ```
   
   Make sure to fund this wallet with SOL for mining operations.

2. **Place the keypair file**

   Copy your `id.json` file to the same directory as the Dockerfile.

3. **Run the setup script**

   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

   This script will:
   - Check if Docker is installed and install it if needed
   - Check if Docker Compose is installed and install it if needed
   - Verify that your Solana keypair exists
   - Build and start the ORE mining container

## Managing the Mining Container

- **View logs**:
  ```bash
  docker-compose logs -f
  ```

- **Stop mining**:
  ```bash
  docker-compose down
  ```

- **Restart mining**:
  ```bash
  docker-compose restart
  ```

- **Check mining status**:
  ```bash
  docker ps | grep ore-miner
  ```

## Auto-start on Boot

To make the mining container start automatically when your system boots:

1. Create a systemd service (Linux):
   ```bash
   sudo nano /etc/systemd/system/ore-miner.service
   ```

2. Add the following content:
   ```
   [Unit]
   Description=ORE Mining Service
   After=docker.service
   Requires=docker.service

   [Service]
   Type=simple
   User=root
   WorkingDirectory=/path/to/ore-docker
   ExecStart=/usr/local/bin/docker-compose up
   ExecStop=/usr/local/bin/docker-compose down
   Restart=always

   [Install]
   WantedBy=multi-user.target
   ```

3. Enable and start the service:
   ```bash
   sudo systemctl enable ore-miner.service
   sudo systemctl start ore-miner.service
   ```

## Troubleshooting

If you encounter issues:

1. Check if the container is running:
   ```bash
   docker ps | grep ore-miner
   ```

2. Inspect the container logs:
   ```bash
   docker-compose logs -f
   ```

3. Try rebuilding the container:
   ```bash
   docker-compose down
   docker-compose build --no-cache
   docker-compose up -d
   ```

4. Make sure your Solana keypair is properly funded with SOL.
