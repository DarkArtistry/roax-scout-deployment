#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo "========================================="
echo -e "${BLUE}Roax Scout Deployment Script${NC}"
echo "========================================="
echo ""

# Check if we're in the right directory
if [ ! -f "docker-compose/docker-compose.yml" ]; then
    echo -e "${RED}Error:${NC} docker-compose/docker-compose.yml not found"
    echo "Please run this script from the roax-scout-deployment directory"
    exit 1
fi

# Pull latest changes
echo -e "${GREEN}[STEP 1/4]${NC} Pulling latest changes..."
git pull origin main

# Navigate to docker-compose directory
cd docker-compose

# Pull latest images
echo -e "${GREEN}[STEP 2/4]${NC} Pulling Docker images..."
docker-compose pull

# Create required directories
echo -e "${GREEN}[STEP 3/4]${NC} Creating data directories..."
mkdir -p ./data/postgres ./data/redis

# Deploy services
echo -e "${GREEN}[STEP 4/4]${NC} Starting services..."
docker-compose up -d

# Wait a moment for services to start
echo ""
echo -e "${YELLOW}Waiting for services to initialize...${NC}"
sleep 10

# Check service status
echo ""
echo -e "${GREEN}Service Status:${NC}"
docker-compose ps

echo ""
echo "========================================="
echo -e "${GREEN}[COMPLETE]${NC} Deployment complete!"
echo "========================================="
echo ""
echo "Access your Blockscout instance at:"
echo "  https://ethglobal-blockscout.roax.network"
echo ""
echo "Useful commands:"
echo "  docker-compose logs -f         # Follow logs"
echo "  docker-compose ps             # Check status"
echo "  docker-compose down           # Stop services"
echo "  docker-compose restart        # Restart services"
echo ""