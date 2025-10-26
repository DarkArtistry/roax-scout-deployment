#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "====================================="
echo "Push Roax Scout Images to Docker Hub"
echo "====================================="
echo ""

# Docker Hub username
DOCKERHUB_USERNAME="darkartistry"

# Check if logged in to Docker Hub
echo -e "${GREEN}[INFO]${NC} Checking Docker Hub login status..."
if ! docker info 2>/dev/null | grep -q "Username: ${DOCKERHUB_USERNAME}"; then
    echo -e "${YELLOW}[WARNING]${NC} Not logged in to Docker Hub. Logging in..."
    docker login -u ${DOCKERHUB_USERNAME}
fi

# Function to tag and push image
push_image() {
    local SOURCE_IMAGE=$1
    local TARGET_IMAGE=$2
    
    echo ""
    echo -e "${GREEN}[INFO]${NC} Processing ${SOURCE_IMAGE}..."
    
    # Check if source image exists
    if docker image inspect "${SOURCE_IMAGE}" >/dev/null 2>&1; then
        echo -e "${GREEN}[INFO]${NC} Found image: ${SOURCE_IMAGE}"
        
        # Tag the image
        echo -e "${GREEN}[INFO]${NC} Tagging as ${TARGET_IMAGE}..."
        docker tag "${SOURCE_IMAGE}" "${TARGET_IMAGE}"
        
        # Push to Docker Hub
        echo -e "${GREEN}[INFO]${NC} Pushing to Docker Hub..."
        docker push "${TARGET_IMAGE}"
        
        echo -e "${GREEN}[SUCCESS]${NC} Successfully pushed ${TARGET_IMAGE}"
    else
        echo -e "${RED}[ERROR]${NC} Image not found: ${SOURCE_IMAGE}"
        echo -e "${YELLOW}[INFO]${NC} Please build this image first"
        return 1
    fi
}

# Push frontend image
echo -e "${GREEN}[STEP 1/2]${NC} Pushing frontend image..."
push_image "roax/blockscout-frontend:validator" "${DOCKERHUB_USERNAME}/blockscout-frontend:validator"

# Push backend image
echo -e "${GREEN}[STEP 2/2]${NC} Pushing backend image..."
push_image "roax/blockscout:validator" "${DOCKERHUB_USERNAME}/blockscout:validator"

echo ""
echo "====================================="
echo -e "${GREEN}[COMPLETE]${NC} Image push completed!"
echo "====================================="
echo ""
echo "Your images are now available on Docker Hub:"
echo "  - ${DOCKERHUB_USERNAME}/blockscout-frontend:validator"
echo "  - ${DOCKERHUB_USERNAME}/blockscout:validator"
echo ""
echo "On your GCE instance, you can pull them with:"
echo "  docker pull ${DOCKERHUB_USERNAME}/blockscout-frontend:validator"
echo "  docker pull ${DOCKERHUB_USERNAME}/blockscout:validator"
echo ""