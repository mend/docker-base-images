#!/bin/bash
set -e

# Script to download all Docker images from ECR for production release
# Usage: ./bin/download-ecr-images.sh <VERSION> <ECR_REGISTRY>

VERSION=$1
ECR_REGISTRY=$2

if [ -z "$VERSION" ] || [ -z "$ECR_REGISTRY" ]; then
    echo "Usage: $0 <VERSION> <ECR_REGISTRY>"
    echo ""
    echo "Example:"
    echo "  $0 25.10.1 123456789012.dkr.ecr.us-east-1.amazonaws.com"
    exit 1
fi

echo "🔽 Downloading all images from ECR..."
echo "Registry: $ECR_REGISTRY"
echo "Version: $VERSION"
echo ""

# Download controller image
echo "📦 Downloading controller image..."
docker pull "$ECR_REGISTRY/base-repo-controller:$VERSION"
echo "✅ Controller image downloaded"

# Download scanner images
echo "📦 Downloading scanner images..."
docker pull "$ECR_REGISTRY/base-repo-scanner:$VERSION"
echo "✅ Scanner image downloaded"

docker pull "$ECR_REGISTRY/base-repo-scanner-full:$VERSION"
echo "✅ Scanner-full image downloaded"

docker pull "$ECR_REGISTRY/base-repo-scanner-sast:$VERSION"
echo "✅ Scanner-sast image downloaded"

# Download remediate image
echo "📦 Downloading remediate image..."
docker pull "$ECR_REGISTRY/base-repo-remediate:$VERSION"
echo "✅ Remediate image downloaded"

echo ""
echo "🎉 All images downloaded successfully!"
echo ""
echo "📋 Downloaded images:"
docker images | grep "$ECR_REGISTRY" | head -20
