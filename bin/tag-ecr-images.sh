#!/bin/bash
set -e

# Script to tag ECR images as Mend images for Docker Hub publishing
# Usage: ./bin/tag-ecr-images.sh <VERSION> <ECR_REGISTRY> <ECR_REPOSITORY>

VERSION=$1
ECR_REGISTRY=$2
ECR_REPOSITORY=$3

if [ -z "$VERSION" ] || [ -z "$ECR_REGISTRY" ] || [ -z "$ECR_REPOSITORY" ]; then
    echo "Usage: $0 <VERSION> <ECR_REGISTRY> <ECR_REPOSITORY>"
    echo ""
    echo "Parameters:"
    echo "  VERSION        - Version tag (e.g., 25.10.1)"
    echo "  ECR_REGISTRY   - ECR registry URL"
    echo "  ECR_REPOSITORY - ECR repository name"
    echo ""
    echo "Example:"
    echo "  $0 25.10.1 123456789012.dkr.ecr.us-east-1.amazonaws.com stg-ghe-base-images"
    exit 1
fi

echo "🏷️ Tagging ECR images for Mend Hub publishing..."
echo "Version: $VERSION"
echo "ECR Registry: $ECR_REGISTRY"
echo "ECR Repository: $ECR_REPOSITORY"
echo ""

# Tag controller image
echo "Tagging controller image..."
docker tag $ECR_REGISTRY/$ECR_REPOSITORY/controller:$VERSION mend/controller:$VERSION
docker tag $ECR_REGISTRY/$ECR_REPOSITORY/controller:$VERSION mend/controller:latest

# Tag scanner images
echo "Tagging scanner images..."
docker tag $ECR_REGISTRY/$ECR_REPOSITORY/scanner:$VERSION mend/scanner:$VERSION
docker tag $ECR_REGISTRY/$ECR_REPOSITORY/scanner:$VERSION mend/scanner:latest

docker tag $ECR_REGISTRY/$ECR_REPOSITORY/scanner-full:$VERSION mend/scanner-full:$VERSION
docker tag $ECR_REGISTRY/$ECR_REPOSITORY/scanner-full:$VERSION mend/scanner-full:latest

docker tag $ECR_REGISTRY/$ECR_REPOSITORY/scanner-sast:$VERSION mend/scanner-sast:$VERSION
docker tag $ECR_REGISTRY/$ECR_REPOSITORY/scanner-sast:$VERSION mend/scanner-sast:latest

# Tag remediate image
echo "Tagging remediate image..."
docker tag $ECR_REGISTRY/$ECR_REPOSITORY/remediate:$VERSION mend/remediate:$VERSION
docker tag $ECR_REGISTRY/$ECR_REPOSITORY/remediate:$VERSION mend/remediate:latest

echo "✅ All images tagged successfully for Mend Hub!"
echo ""
echo "📋 Tagged images:"
docker images --filter="reference=mend/*" --format "table {{.Repository}}:{{.Tag}}" | head -20
