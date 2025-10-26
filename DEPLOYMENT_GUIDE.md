# Roax Scout Deployment Guide for Google Compute Engine

## Table of Contents
1. [GCE Instance Specifications](#gce-instance-specifications)
2. [Repository Forking Strategy](#repository-forking-strategy)
3. [Environment Variables](#environment-variables)
4. [Deployment Steps](#deployment-steps)
5. [SSL Configuration with Let's Encrypt](#ssl-configuration)
6. [Monitoring and Maintenance](#monitoring-and-maintenance)

## GCE Instance Specifications

### Minimum Requirements
```
Machine Type: e2-standard-4 (or equivalent)
vCPUs: 4
Memory: 16 GB RAM
Boot Disk: 100 GB SSD (pd-ssd)
OS: Ubuntu 22.04 LTS
Network: Allow HTTP (80) and HTTPS (443) traffic
```

### Recommended Production Specifications

#### Option 1: ARM-based Instance (Matches your local builds)
```
Machine Type: t2a-standard-8
Architecture: ARM64
vCPUs: 8
Memory: 32 GB RAM
Boot Disk: 200 GB SSD (pd-ssd)
Additional Disk: 500 GB SSD for database storage
OS: Ubuntu 22.04 LTS
Network: Allow HTTP (80) and HTTPS (443) traffic
Static External IP: Required for domain mapping
```

#### Option 2: x86-based Instance (Requires multi-arch builds)
```
Machine Type: n2-standard-8
Architecture: x86_64
vCPUs: 8
Memory: 32 GB RAM
Boot Disk: 200 GB SSD (pd-ssd)
Additional Disk: 500 GB SSD for database storage
OS: Ubuntu 22.04 LTS
Network: Allow HTTP (80) and HTTPS (443) traffic
Static External IP: Required for domain mapping
```

**Important Architecture Consideration**: Your Docker images are currently built for ARM64. Choose one approach:
1. **Use ARM instance (t2a-standard-8)** - Simpler, your existing images will work
2. **Use x86 instance (n2-standard-8)** - Better compatibility, but requires building multi-architecture images

### Resource Breakdown by Service
- **PostgreSQL Database**: 4-8 GB RAM, 100+ GB storage
- **Backend (Elixir)**: 4-8 GB RAM
- **Frontend (Next.js)**: 2-4 GB RAM
- **Redis**: 1-2 GB RAM
- **Supporting Services**: 2-4 GB RAM combined
- **Docker/System Overhead**: 2-4 GB RAM

## Architecture Decision

**Your current setup uses ARM64** (Apple Silicon), so you have two deployment options:

1. **Recommended: Use GCE ARM instances (t2a-standard-8)**
   - Pros: Your existing images work without modification
   - Cons: Slightly less third-party software compatibility
   
2. **Alternative: Use GCE x86 instances (n2-standard-8)**
   - Pros: Better ecosystem support, more software options
   - Cons: Requires building multi-architecture images

## Repository Forking Strategy

### Step 1: Fork the Blockscout Repositories

1. **Fork blockscout-backend**:
   ```bash
   # Go to https://github.com/blockscout/blockscout
   # Click Fork and create your fork
   # Clone your fork
   git clone https://github.com/YOUR_USERNAME/blockscout.git blockscout-backend-fork
   cd blockscout-backend-fork
   
   # Add upstream remote
   git remote add upstream https://github.com/blockscout/blockscout.git
   ```

2. **Fork blockscout-frontend**:
   ```bash
   # Go to https://github.com/blockscout/frontend
   # Click Fork and create your fork
   # Clone your fork
   git clone https://github.com/YOUR_USERNAME/frontend.git blockscout-frontend-fork
   cd blockscout-frontend-fork
   
   # Add upstream remote
   git remote add upstream https://github.com/blockscout/frontend.git
   ```

### Step 2: Apply Roax Customizations

1. **Copy your customizations to the forks**:
   ```bash
   # For backend (if any custom changes exist)
   cp -r /path/to/roax-scout/blockscout-backend/* ./blockscout-backend-fork/
   
   # For frontend
   cp -r /path/to/roax-scout/blockscout-frontend/* ./blockscout-frontend-fork/
   ```

2. **Commit and push changes**:
   ```bash
   # Frontend fork
   cd blockscout-frontend-fork
   git add .
   git commit -m "Add Roax network customizations and Blockscout SDK integration"
   git push origin main
   
   # Backend fork (if customized)
   cd ../blockscout-backend-fork
   git add .
   git commit -m "Add Roax network configuration"
   git push origin main
   ```

### Step 3: Create Main Deployment Repository

1. **Create a new repository for Roax Scout**:
   ```bash
   # Create new repo on GitHub: roax-scout-deployment
   mkdir roax-scout-deployment
   cd roax-scout-deployment
   git init
   ```

2. **Create deployment structure**:
   ```bash
   # Copy deployment files
   cp -r /path/to/roax-scout/blockscout-backend/docker-compose ./
   cp -r /path/to/roax-scout/deploy-local.sh ./
   cp -r /path/to/roax-scout/*.md ./
   
   # Create .gitignore
   cat > .gitignore << EOF
   .env
   .env.local
   *.log
   .DS_Store
   data/
   EOF
   ```

3. **Update docker-compose configuration to use your Docker Hub images**:
   
   In `docker-compose/services/frontend.yml`:
   ```yaml
   services:
     frontend:
       image: YOUR_DOCKERHUB_USERNAME/blockscout-frontend:validator
       pull_policy: always
       # ... rest of configuration
   ```
   
   In `docker-compose/docker-compose.yml`:
   ```yaml
   services:
     backend:
       image: YOUR_DOCKERHUB_USERNAME/blockscout:validator
       pull_policy: always
       # ... rest of configuration
   ```

4. **Create deployment scripts**:
   ```bash
   # Create deploy.sh
   cat > deploy.sh << 'EOF'
   #!/bin/bash
   set -e
   
   # Pull latest changes
   git pull origin main
   
   # Update submodules if using
   git submodule update --init --recursive
   
   # Deploy with docker-compose
   cd docker-compose
   docker-compose pull
   docker-compose up -d
   EOF
   
   chmod +x deploy.sh
   ```

5. **Commit and push**:
   ```bash
   git add .
   git commit -m "Initial MEGA Blockscout deployment configuration"
   git remote add origin https://github.com/YOUR_USERNAME/mega-blockscout-deployment.git
   git push -u origin main
   ```

## Environment Variables

### Critical Environment Variables to Configure

Create `.env` files in your deployment repository:

**docker-compose/envs/common-blockscout.env**:
```bash
# Network Configuration
ETHEREUM_JSONRPC_VARIANT=geth
ETHEREUM_JSONRPC_HTTP_URL=https://devrpc.roax.network
ETHEREUM_JSONRPC_TRACE_URL=https://devrpc.roax.network
ETHEREUM_JSONRPC_WS_URL=wss://devrpc.roax.network
CHAIN_ID=135

# Database
DATABASE_URL=postgresql://blockscout:YOUR_SECURE_PASSWORD@db:5432/blockscout

# Security
SECRET_KEY_BASE=YOUR_GENERATED_SECRET_KEY # Generate with: mix phx.gen.secret
ACCOUNT_CLOAK_KEY=YOUR_GENERATED_CLOAK_KEY # Generate with: mix phx.gen.secret

# Features
INDEXER_BEACON_RPC_URL=https://devbeacon.roax.network
MICROSERVICE_SC_VERIFIER_TYPE=eth_bytecode_db
MICROSERVICE_VISUALIZE_SOL2UML_ENABLED=true
MICROSERVICE_SIG_PROVIDER_ENABLED=true

# Network Details
COIN_NAME=PLASMA
NETWORK_NAME=ROAX Tricca TestNet
```

**Note about Backend Image**: The backend uses a pre-built image `roax/blockscout:validator` (ARM64). For deployment:
- **ARM instance**: Use the existing image as-is (transfer via Docker Hub as shown in deployment steps)
- **x86 instance**: You'll need to either:
  - Get an x86 version of this image from the source
  - Build your own backend image from the Blockscout source
  - Contact the image provider for multi-arch support

**docker-compose/envs/common-frontend.env**:
```bash
# API Configuration (Update for production domain)
NEXT_PUBLIC_API_HOST=ethglobal-blockscout.roax.network
NEXT_PUBLIC_API_PROTOCOL=https
NEXT_PUBLIC_STATS_API_HOST=https://ethglobal-blockscout.roax.network:8080

# Network Information
NEXT_PUBLIC_NETWORK_NAME=ROAX Tricca TestNet
NEXT_PUBLIC_NETWORK_SHORT_NAME=ROAX
NEXT_PUBLIC_NETWORK_ID=135
NEXT_PUBLIC_NETWORK_CURRENCY_NAME=PLASMA
NEXT_PUBLIC_NETWORK_CURRENCY_SYMBOL=PLASMA
NEXT_PUBLIC_NETWORK_CURRENCY_DECIMALS=18

# Features
NEXT_PUBLIC_VALIDATORS_CHAIN_TYPE=beacon
NEXT_PUBLIC_CONTRACT_EDITOR_ENABLED=true
NEXT_PUBLIC_IS_TESTNET=true

# Wallet Connect (Required for blockchain interaction)
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=YOUR_WALLET_CONNECT_PROJECT_ID

# Blockchain RPC (for wallet interactions)
NEXT_PUBLIC_NETWORK_RPC_URL=https://devrpc.roax.network

# API WebSocket
NEXT_PUBLIC_API_WEBSOCKET_PROTOCOL=wss
```

## Deployment Steps

### On Your GCE Instance

1. **Initial Setup**:
   ```bash
   # Update system
   sudo apt update && sudo apt upgrade -y
   
   # Install Docker
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   sudo usermod -aG docker $USER
   newgrp docker
   
   # Install Docker Compose
   sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   
   # Install Git
   sudo apt install git -y
   
   # Install Nginx for SSL termination
   sudo apt install nginx certbot python3-certbot-nginx -y
   ```

2. **Clone Deployment Repository**:
   ```bash
   cd /opt
   sudo git clone https://github.com/YOUR_USERNAME/roax-scout-deployment.git
   sudo chown -R $USER:$USER roax-scout-deployment
   cd roax-scout-deployment
   ```

3. **Build and Transfer Images**:

   **For ARM64 Instance (t2a series)**:
   
   Since you have ARM64 images locally, you need to transfer them to your GCE instance:

   **Option A - Via Docker Registry (Recommended)**:
   ```bash
   # On your local machine
   # Use the provided script to push images
   ./push-to-dockerhub.sh
   
   # Or manually:
   docker login -u YOUR_DOCKERHUB_USERNAME
   docker tag roax/blockscout-frontend:validator YOUR_DOCKERHUB_USERNAME/blockscout-frontend:validator
   docker tag roax/blockscout:validator YOUR_DOCKERHUB_USERNAME/blockscout:validator
   docker push YOUR_DOCKERHUB_USERNAME/blockscout-frontend:validator
   docker push YOUR_DOCKERHUB_USERNAME/blockscout:validator
   ```
   
   Note: The docker-compose files have been updated to pull from Docker Hub automatically.

   **Option B - Build on GCE Instance**:
   ```bash
   # Clone your frontend fork on the GCE instance
   git clone https://github.com/YOUR_USERNAME/frontend.git blockscout-frontend
   cd blockscout-frontend
   
   # Build the image with production args
   docker build \
     --build-arg NEXT_PUBLIC_API_HOST=ethglobal-blockscout.roax.network \
     --build-arg NEXT_PUBLIC_API_PROTOCOL=https \
     --build-arg NEXT_PUBLIC_NETWORK_ID=135 \
     --build-arg NEXT_PUBLIC_NETWORK_NAME="ROAX Tricca TestNet" \
     --build-arg NEXT_PUBLIC_NETWORK_CURRENCY_SYMBOL=PLASMA \
     --build-arg NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=YOUR_PROJECT_ID \
     -t roax/blockscout-frontend:validator .
   
   cd ..
   ```

   **For x86_64 Instance (n2 series) - Build multi-arch**:
   ```bash
   # Enable Docker buildx
   docker buildx create --use --name multiarch-builder
   docker buildx inspect --bootstrap
   
   # Clone your frontend fork
   git clone https://github.com/YOUR_USERNAME/frontend.git blockscout-frontend
   cd blockscout-frontend
   
   # Build multi-architecture image and push to registry
   docker buildx build \
     --platform linux/amd64,linux/arm64 \
     --build-arg NEXT_PUBLIC_API_HOST=ethglobal-blockscout.roax.network \
     --build-arg NEXT_PUBLIC_API_PROTOCOL=https \
     --build-arg NEXT_PUBLIC_NETWORK_ID=135 \
     --build-arg NEXT_PUBLIC_NETWORK_NAME="ROAX Tricca TestNet" \
     --build-arg NEXT_PUBLIC_NETWORK_CURRENCY_SYMBOL=PLASMA \
     --build-arg NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=YOUR_PROJECT_ID \
     -t YOUR_DOCKERHUB_USERNAME/blockscout-frontend:validator \
     --push .
   
   # For backend (if you have custom backend image)
   docker buildx build \
     --platform linux/amd64,linux/arm64 \
     -t YOUR_DOCKERHUB_USERNAME/blockscout-backend:validator \
     --push .
   
   cd ..
   ```

   **Note**: For x86 deployment, you'll need to:
   - Have a Docker Hub account (or other registry)
   - Update your docker-compose.yml to pull from the registry
   - The multi-arch build will take longer but works on both architectures

4. **Start Services**:
   ```bash
   cd docker-compose
   
   # Create required directories
   mkdir -p ./data/postgres ./data/redis
   
   # Start services
   docker-compose up -d
   
   # Check logs
   docker-compose logs -f
   ```

## SSL Configuration

### Configure Nginx with Let's Encrypt

1. **Create Nginx configuration**:
   ```bash
   sudo nano /etc/nginx/sites-available/blockscout
   ```

   Add:
   ```nginx
   server {
       listen 80;
       server_name ethglobal-blockscout.roax.network;
       
       location /.well-known/acme-challenge/ {
           root /var/www/certbot;
       }
       
       location / {
           return 301 https://$server_name$request_uri;
       }
   }
   
   server {
       listen 443 ssl;
       server_name ethglobal-blockscout.roax.network;
       
       ssl_certificate /etc/letsencrypt/live/ethglobal-blockscout.roax.network/fullchain.pem;
       ssl_certificate_key /etc/letsencrypt/live/ethglobal-blockscout.roax.network/privkey.pem;
       
       # Security headers
       add_header Strict-Transport-Security "max-age=31536000" always;
       add_header X-Frame-Options "SAMEORIGIN" always;
       add_header X-Content-Type-Options "nosniff" always;
       
       # Main app
       location / {
           proxy_pass http://localhost:80;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
       
       # API
       location /api {
           proxy_pass http://localhost:80/api;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
       
       # WebSocket
       location /socket {
           proxy_pass http://localhost:80/socket;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection "upgrade";
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
       
       # Stats API
       location /stats {
           proxy_pass http://localhost:8080;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
   }
   ```

2. **Enable site and get certificate**:
   ```bash
   sudo ln -s /etc/nginx/sites-available/blockscout /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl reload nginx
   
   # Get SSL certificate
   sudo certbot --nginx -d ethglobal-blockscout.roax.network
   ```

3. **Set up auto-renewal**:
   ```bash
   sudo crontab -e
   # Add:
   0 12 * * * /usr/bin/certbot renew --quiet
   ```

## Continuous Deployment

### GitHub Actions Workflow

Create `.github/workflows/deploy.yml` in your deployment repository:

```yaml
name: Deploy to GCE

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to GCE
      uses: appleboy/ssh-action@v0.1.5
      with:
        host: ${{ secrets.GCE_HOST }}
        username: ${{ secrets.GCE_USER }}
        key: ${{ secrets.GCE_SSH_KEY }}
        script: |
          cd /opt/roax-scout-deployment
          git pull origin main
          cd docker-compose
          docker-compose pull
          docker-compose up -d
          docker system prune -f
```

### Setting up SSH Access

1. **Generate SSH key pair locally**:
   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/gce_deploy_key
   ```

2. **Add public key to GCE instance**:
   ```bash
   # On GCE instance
   echo "YOUR_PUBLIC_KEY" >> ~/.ssh/authorized_keys
   ```

3. **Add secrets to GitHub**:
   - `GCE_HOST`: Your instance IP
   - `GCE_USER`: Your username
   - `GCE_SSH_KEY`: Private key content

## Monitoring and Maintenance

### Health Checks

Create `health-check.sh`:
```bash
#!/bin/bash

# Check all services
echo "Checking service health..."

# Frontend
if curl -s http://localhost > /dev/null; then
    echo "✓ Frontend is running"
else
    echo "✗ Frontend is down"
fi

# Backend API
if curl -s http://localhost/api/v1/health > /dev/null; then
    echo "✓ Backend API is running"
else
    echo "✗ Backend API is down"
fi

# Database
if docker-compose exec db pg_isready > /dev/null 2>&1; then
    echo "✓ Database is running"
else
    echo "✗ Database is down"
fi

# Redis
if docker-compose exec redis-db redis-cli ping > /dev/null 2>&1; then
    echo "✓ Redis is running"
else
    echo "✗ Redis is down"
fi
```

### Backup Strategy

1. **Database Backup**:
   ```bash
   # Create backup script
   cat > backup-db.sh << 'EOF'
   #!/bin/bash
   DATE=$(date +%Y%m%d_%H%M%S)
   docker-compose exec -T db pg_dump -U blockscout blockscout | gzip > backup_$DATE.sql.gz
   # Upload to Google Cloud Storage
   gsutil cp backup_$DATE.sql.gz gs://your-backup-bucket/
   # Keep only last 7 days locally
   find . -name "backup_*.sql.gz" -mtime +7 -delete
   EOF
   
   chmod +x backup-db.sh
   
   # Add to crontab
   0 3 * * * /opt/roax-scout-deployment/backup-db.sh
   ```

2. **Log Rotation**:
   ```bash
   # Create logrotate config
   sudo nano /etc/logrotate.d/docker-blockscout
   ```
   
   Add:
   ```
   /var/lib/docker/containers/*/*.log {
       rotate 7
       daily
       compress
       missingok
       delaycompress
       copytruncate
   }
   ```

### Monitoring Setup

1. **Install monitoring stack**:
   ```bash
   # Add to docker-compose.yml
   prometheus:
     image: prom/prometheus
     volumes:
       - ./prometheus.yml:/etc/prometheus/prometheus.yml
     ports:
       - "9090:9090"
   
   grafana:
     image: grafana/grafana
     ports:
       - "3001:3000"
     environment:
       - GF_SECURITY_ADMIN_PASSWORD=YOUR_SECURE_PASSWORD
   ```

2. **Configure alerts**:
   ```yaml
   # prometheus.yml
   global:
     scrape_interval: 15s
   
   scrape_configs:
     - job_name: 'blockscout'
       static_configs:
         - targets: ['backend:4000']
   ```

## Troubleshooting

### Common Issues

1. **Frontend 502 Bad Gateway**:
   ```bash
   # Check frontend logs
   docker-compose logs frontend
   
   # Rebuild if necessary
   docker-compose up -d --build frontend
   ```

2. **Database Connection Issues**:
   ```bash
   # Check database logs
   docker-compose logs db
   
   # Reset database if needed
   docker-compose down -v
   docker-compose up -d db
   docker-compose up -d
   ```

3. **Memory Issues**:
   ```bash
   # Check memory usage
   docker stats
   
   # Add swap if needed
   sudo fallocate -l 8G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   ```

## Security Considerations

1. **Firewall Rules**:
   ```bash
   # Configure UFW
   sudo ufw allow 22/tcp
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw enable
   ```

2. **Environment Variables**:
   - Never commit `.env` files
   - Use strong passwords for database
   - Rotate secret keys regularly

3. **Updates**:
   ```bash
   # Regular system updates
   sudo apt update && sudo apt upgrade -y
   
   # Docker updates
   docker-compose pull
   docker-compose up -d
   ```

## Updating from Upstream

To update your forks with latest Blockscout changes:

```bash
# Frontend
cd blockscout-frontend-fork
git fetch upstream
git checkout main
git merge upstream/main
# Resolve conflicts if any
git push origin main

# Backend (if customized)
cd ../blockscout-backend-fork
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
```

Then redeploy by pushing to your deployment repository.