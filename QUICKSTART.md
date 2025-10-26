# Quick Start Guide - Roax Scout Explorer

Get your Roax blockchain explorer running locally in under 10 minutes.

## Prerequisites Check

Before starting, ensure you have:

```bash
# Check Docker version (need v20.10+)
docker --version

# Check Docker Compose version (need v2.x.x+)
docker compose version

# Verify Docker is running
docker ps
```

## Quick Start Steps

### 1. Navigate to Docker Compose Directory

```bash
cd blockscout/docker-compose
```

### 2. Configure for Roax Network

The custom Roax configuration files are already created:
- `roax.yml` - Docker compose configuration
- `envs/roax-blockscout.env` - Backend configuration
- `envs/roax-frontend.env` - Frontend configuration

To use these configurations, you need to update the service definitions to use the Roax-specific environment files.

### 3. Update Service Configurations

Edit `services/backend.yml` to add the Roax environment file:

```bash
# Backup the original
cp services/backend.yml services/backend.yml.backup
```

Then modify the backend service to load the Roax environment:
```yaml
env_file:
  - ./envs/roax-blockscout.env
```

Similarly for `services/frontend.yml`:
```yaml
env_file:
  - ./envs/roax-frontend.env
```

### 4. Start the Explorer

```bash
# Start all services
docker compose -f roax.yml up -d

# Follow the logs
docker compose -f roax.yml logs -f
```

### 5. Wait for Initialization

First-time startup takes 5-10 minutes:
- Database initialization
- Backend compilation
- Frontend build
- Service health checks

Monitor progress:
```bash
# Watch backend initialization
docker compose -f roax.yml logs -f backend

# Check service status
docker compose -f roax.yml ps
```

### 6. Access the Explorer

Once all services are running:

- **Frontend**: http://localhost
- **Backend API**: http://localhost/api/v2
- **Stats API**: http://localhost:8080
- **API Documentation**: http://localhost/api-docs

### 7. Verify It's Working

Check the API health:
```bash
curl http://localhost/api/v1/health
```

Expected response:
```json
{
  "healthy": true
}
```

## Common First-Time Issues

### Issue: Port Already in Use

If port 80 is already in use, you can change the proxy port:

1. Edit `services/nginx.yml`
2. Change port mapping from `80:80` to `8080:80`
3. Access at http://localhost:8080

### Issue: Backend Takes Long to Start

The backend needs to compile Elixir code on first run. This is normal and can take 3-5 minutes.

```bash
# Check compilation progress
docker compose -f roax.yml logs backend | grep "Compiling"
```

### Issue: Database Connection Errors

Make sure the database initialized properly:

```bash
# Check database logs
docker compose -f roax.yml logs db

# Restart if needed
docker compose -f roax.yml restart backend
```

### Issue: Cannot Connect to RPC

Verify the Roax RPC is accessible:

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  https://devrpc.roax.network
```

If this fails, your RPC endpoint might be down or unreachable.

## Stopping the Explorer

```bash
# Stop all services
docker compose -f roax.yml down

# Stop and remove all data (complete reset)
docker compose -f roax.yml down -v
```

## Quick Commands Reference

```bash
# Start services
docker compose -f roax.yml up -d

# Stop services
docker compose -f roax.yml down

# View logs for all services
docker compose -f roax.yml logs -f

# View logs for specific service
docker compose -f roax.yml logs -f backend
docker compose -f roax.yml logs -f frontend

# Check service status
docker compose -f roax.yml ps

# Restart a specific service
docker compose -f roax.yml restart backend

# Access backend shell
docker compose -f roax.yml exec backend bash

# Access database
docker compose -f roax.yml exec db psql -U blockscout
```

## Alternative: Using Existing Geth Config

If you prefer to use the existing `geth.yml` configuration, you can modify the environment files directly:

```bash
# Edit the backend configuration
nano envs/common-blockscout.env

# Update these values:
# ETHEREUM_JSONRPC_HTTP_URL=https://devrpc.roax.network
# ETHEREUM_JSONRPC_TRACE_URL=https://devrpc.roax.network
# CHAIN_ID=135
# COIN=PLASMA
# COIN_NAME=PLASMA

# Edit the frontend configuration
nano envs/common-frontend.env

# Update these values:
# NEXT_PUBLIC_NETWORK_NAME=Roax Network
# NEXT_PUBLIC_NETWORK_ID=135
# NEXT_PUBLIC_NETWORK_CURRENCY_NAME=PLASMA
# NEXT_PUBLIC_NETWORK_CURRENCY_SYMBOL=PLASMA

# Start with geth configuration
docker compose -f geth.yml up -d
```

## Next Steps

After your explorer is running:

1. **Monitor Indexing Progress**
   - Check the latest block indexed: http://localhost/api/v1/stats
   - Compare with your chain's latest block

2. **Test Smart Contract Verification**
   - Deploy a test contract to Roax network
   - Try verifying it through the explorer

3. **Configure Production Settings**
   - See the main README.md for production deployment
   - Set up SSL certificates
   - Configure domain names
   - Enable monitoring

4. **Customize the Explorer**
   - Add custom branding
   - Configure additional features
   - Add custom tabs (see main README)

## Getting Help

If you encounter issues:

1. Check the logs: `docker compose -f roax.yml logs`
2. Verify RPC connectivity
3. Ensure all services are running: `docker compose -f roax.yml ps`
4. Review the main README.md for detailed troubleshooting
5. Check Blockscout documentation: https://docs.blockscout.com/

## Health Check Checklist

After startup, verify all components:

- [ ] Database is running
- [ ] Redis is running
- [ ] Backend is running and healthy
- [ ] Frontend is accessible
- [ ] Stats service is running
- [ ] Blocks are being indexed
- [ ] API responds correctly
- [ ] No error logs in any service

Run this comprehensive check:

```bash
#!/bin/bash
echo "=== Service Status ==="
docker compose -f roax.yml ps

echo -e "\n=== Backend Health ==="
curl -s http://localhost/api/v1/health | jq .

echo -e "\n=== Latest Block ==="
curl -s http://localhost/api/v1/stats | jq .total_blocks

echo -e "\n=== RPC Connectivity ==="
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  https://devrpc.roax.network | jq .
```

Save this as `health-check.sh`, make it executable with `chmod +x health-check.sh`, and run it to verify everything is working.
