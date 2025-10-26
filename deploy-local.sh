#!/bin/bash

# MEGA Blockscout - Local Deployment Script
# This script helps you deploy the MEGA Blockscout (Make Ethereum Great Again) explorer locally

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DOCKER_COMPOSE_FILE="docker-compose.yml"
COMPOSE_DIR="blockscout-backend/docker-compose"

echo "====================================="
echo "MEGA Blockscout - Local Deployment"
echo "===================================="
echo ""

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
print_info "Checking prerequisites..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! docker compose version &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose v2 first."
    exit 1
fi

# Check Docker version
DOCKER_VERSION=$(docker --version | grep -oE '[0-9]+\.[0-9]+' | head -1)
print_info "Docker version: $DOCKER_VERSION"

# Check if Docker is running
if ! docker ps &> /dev/null; then
    print_error "Docker is not running. Please start Docker first."
    exit 1
fi

print_info "Prerequisites check passed!"
echo ""

# Navigate to docker-compose directory
if [ ! -d "$COMPOSE_DIR" ]; then
    print_error "Directory $COMPOSE_DIR not found. Please run this script from the mega-blockscout root directory."
    exit 1
fi

cd "$COMPOSE_DIR"
print_info "Working directory: $(pwd)"
echo ""

# Check if configuration files exist
print_info "Checking configuration files..."

if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    print_error "Configuration file $DOCKER_COMPOSE_FILE not found."
    exit 1
fi

if [ ! -f "envs/common-blockscout.env" ]; then
    print_warning "Backend environment file not found. Using default configuration."
fi

if [ ! -f "envs/common-frontend.env" ]; then
    print_warning "Frontend environment file not found. Using default configuration."
fi

echo ""

# Test RPC connectivity
print_info "Testing Roax RPC connectivity..."
if curl -s -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  https://devrpc.roax.network > /dev/null; then
    print_info "RPC connection successful!"
else
    print_warning "Could not connect to Roax RPC at https://devrpc.roax.network"
    print_warning "The explorer will start but may not be able to sync blocks."
    echo ""
    read -p "Do you want to continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""

# Ask user if they want to proceed
print_info "This will start the following services:"
echo "  - PostgreSQL database"
echo "  - Redis cache"
echo "  - MEGA Blockscout backend (with validator APIs)"
echo "  - MEGA Blockscout frontend (with IDE & SDK)"
echo "  - Stats service"
echo "  - Visualizer service"
echo "  - Signature provider"
echo "  - User operations indexer"
echo "  - Nginx proxy"
echo ""

read -p "Do you want to proceed? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Deployment cancelled."
    exit 0
fi

echo ""

# Check for locally built frontend image
print_info "Checking for locally built frontend image..."
if docker images | grep -q "roax/blockscout-frontend.*validator"; then
    print_info "Found locally built frontend image: roax/blockscout-frontend:validator"
else
    print_warning "Local frontend image not found. The container may fail to start."
    print_warning "Build it with: cd ../blockscout-frontend && docker build --no-cache -t roax/blockscout-frontend:validator ."
fi

echo ""

# Start services
print_info "Starting services..."
print_info "This may take 5-10 minutes on first run..."
echo ""

docker compose -f "$DOCKER_COMPOSE_FILE" up -d

echo ""
print_info "Services started!"
echo ""

# Wait for services to be healthy
print_info "Waiting for services to initialize..."
sleep 10

# Check service status
print_info "Service status:"
docker compose -f "$DOCKER_COMPOSE_FILE" ps

echo ""
echo "====================================="
print_info "Deployment Summary"
echo "====================================="
echo ""
echo "Frontend:     http://localhost"
echo "Backend API:  http://localhost/api"
echo "Stats API:    http://localhost:8080"
echo "API Docs:     http://localhost/api-docs"
echo ""
echo "To view logs:"
echo "  docker compose -f $DOCKER_COMPOSE_FILE logs -f"
echo ""
echo "To stop services:"
echo "  docker compose -f $DOCKER_COMPOSE_FILE down"
echo ""
echo "To stop and remove all data:"
echo "  docker compose -f $DOCKER_COMPOSE_FILE down -v"
echo ""

# Check if services are responding
print_info "Checking service health (this may take a minute)..."
sleep 15

if curl -s http://localhost > /dev/null 2>&1; then
    print_info "Frontend is responding!"
else
    print_warning "Frontend is not yet responding. It may still be starting up."
    echo "  Check logs: docker compose -f $DOCKER_COMPOSE_FILE logs frontend"
fi

if curl -s http://localhost/api/v1/health > /dev/null 2>&1; then
    print_info "Backend API is responding!"
else
    print_warning "Backend API is not yet responding. It may still be starting up."
    echo "  Check logs: docker compose -f $DOCKER_COMPOSE_FILE logs backend"
fi

echo ""
print_info "MEGA Blockscout deployment complete!"
print_info "The services are starting up. Please wait a few minutes for full initialization."
print_info "Visit the Smart Contract IDE at http://localhost/ide"
print_info "View validator dashboard at http://localhost/validators"
echo ""

# Offer to follow logs
read -p "Do you want to follow the logs? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    print_info "Following logs... (Press Ctrl+C to exit)"
    docker compose -f "$DOCKER_COMPOSE_FILE" logs -f
fi
