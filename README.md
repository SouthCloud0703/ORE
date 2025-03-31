# Dockerized ORE Mining

このプロジェクトはORE暗号通貨のマイニングをDockerコンテナを使って自動化します。

## 前提条件

- Docker と Docker Compose
- SOLが入金されたSolanaキーペア

## ORE Mining Mechanism

ORE暗号通貨は独自のマイニングと報酬メカニズムを使用しています：

1. **マイニングプロセス**:
   - マイナーはハッシュ計算結果を約1分に1回提出します
   - 報酬はハッシュの難易度に基づいて計算されます（より多くの先頭ゼロ = より高い報酬）
   - 報酬はブロックチェーン上の「proofアカウント」に蓄積されます

2. **報酬の受け取り**:
   - 報酬は自動的にウォレットに反映されません
   - `ore claim`コマンドを使用して蓄積された報酬を請求する必要があります
   - 当Dockerセットアップでは1時間ごとに自動的に報酬を請求します

3. **タイミングに関する考慮事項**:
   - ハッシュ提出は約1分に1回に制限されています
   - 遅延提出（時間枠を超えた場合）は減額された報酬を受け取ります
   - プロトコルはネットワークのハッシュパワーに基づいて報酬率を調整します

## セットアップ手順

1. **Solanaキーペアの準備**

   Solanaキーペアがない場合は、新しく作成してください：
   ```bash
   solana-keygen new --outfile id.json
   ```
   
   このウォレットには、マイニング操作用にSOLを入金してください。

2. **キーペアファイルの配置**

   生成したid.jsonファイルをDockerfileと同じディレクトリに配置します。
   
   **セキュリティに関する重要な注意**: 
   - `id.json` ファイルは `.gitignore` に追加されており、GitHubにはプッシュされません
   - **絶対に** 秘密鍵をパブリックリポジトリにプッシュしないでください

3. **セットアップスクリプトの実行**

   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

   このスクリプトは以下を行います：
   - Dockerがインストールされているか確認し、必要に応じてインストール
   - Docker Composeがインストールされているか確認し、必要に応じてインストール
   - Solanaキーペアの存在を確認
   - OREマイニングコンテナをビルドして起動

## マイニングコンテナの管理

- **ログの表示**:
  ```bash
  docker-compose logs -f
  ```

- **マイニングの停止**:
  ```bash
  docker-compose down
  ```

- **マイニングの再起動**:
  ```bash
  docker-compose restart
  ```

- **マイニング状況の確認**:
  ```bash
  docker ps | grep ore-miner
  ```

- **報酬状況の確認**:
  ```bash
  docker exec -it ore-miner ore account
  ```

- **手動で報酬を請求**:
  ```bash
  docker exec -it ore-miner ore claim all
  ```

## 起動時の自動起動設定

システム起動時にマイニングコンテナが自動的に起動するようにするには：

1. systemdサービスを作成（Linux）：
   ```bash
   sudo nano /etc/systemd/system/ore-miner.service
   ```

2. 以下の内容を追加：
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

3. サービスを有効にして起動：
   ```bash
   sudo systemctl enable ore-miner.service
   sudo systemctl start ore-miner.service
   ```

## トラブルシューティング

問題が発生した場合：

1. コンテナが実行中か確認：
   ```bash
   docker ps | grep ore-miner
   ```

2. コンテナログの確認：
   ```bash
   docker-compose logs -f
   ```

3. コンテナの再ビルド：
   ```bash
   docker-compose down
   docker-compose build --no-cache
   docker-compose up -d
   ```

4. Solanaキーペアに十分なSOLが入金されているか確認してください。

## Useful Links

- **公式ウェブサイト**: [ore.supply](https://ore.supply/)
- **トークン情報**: [DEX Screener - ORE/SOL](https://dexscreener.com/solana/ggadtfbqdgjozz3fp7zrtofgwnrs4e6mczmmd5ni1)
- **Discordコミュニティ**: サポートと最新情報についてはDiscordに参加してください
