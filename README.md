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

2. **Solanaキーペアファイル（id.json）の準備**

   マイニングを開始するには、Solanaウォレットのキーペアファイル（`id.json`）が必要です。
   
   **id.jsonファイルの取得方法**:
   ```bash
   # 新しいSolanaキーペアを生成
   solana-keygen new --outfile id.json
   
   # 生成されたウォレットアドレスを確認
   solana address -k id.json
   ```
   
   **必要な資金**:
   - マイニングを行うには、ウォレットに最低0.005 SOLが必要です
   - 継続的な運用のためには0.1 SOL以上を推奨します
   
   **SOLの入金方法**:
   ```bash
   # Devnetで開発している場合（本番環境では使用できません）
   solana airdrop 1 <YOUR_WALLET_ADDRESS> --url https://api.devnet.solana.com
   
   # 残高確認
   solana balance -k id.json
   ```
   
   生成した`id.json`ファイルをDockerfileと同じディレクトリに配置してください。
   
   **セキュリティに関する重要な注意**: 
   - `id.json` ファイルは `.gitignore` に追加されており、GitHubにはプッシュされません
   - **絶対に** 秘密鍵をパブリックリポジトリにプッシュしないでください
   - このファイルは秘密鍵を含むため、厳重に管理してください

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

## Useful Links

- **Official Website**: [ore.supply](https://ore.supply/)
- **Token Information**: [DEX Screener - ORE/SOL](https://dexscreener.com/solana/ggadtfbqdgjozz3fp7zrtofgwnrs4e6mczmmd5ni1)
- **Discord Community**: Join the Discord for support and updates

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
