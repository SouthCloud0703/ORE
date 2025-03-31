#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing Docker..."
    
    # Install Docker based on platform
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux installation
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io
        sudo systemctl enable docker
        sudo systemctl start docker
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # MacOS installation
        echo "Please install Docker Desktop for Mac from https://www.docker.com/products/docker-desktop"
        exit 1
    else
        echo "Unsupported OS. Please install Docker manually."
        exit 1
    fi
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Check if Solana keypair exists
if [ ! -f "./id.json" ]; then
    echo "Solana keypair not found. Please create a keypair using 'solana-keygen new' and save it as id.json in this directory."
    echo "Make sure your keypair is funded with enough SOL for mining operations."
    exit 1
fi

# Build and start the Docker container
echo "Building and starting ORE mining container..."
docker-compose up -d

echo "ORE mining container is now running in the background."
echo "To check logs: docker-compose logs -f"
echo "To stop mining: docker-compose down"
