#!/bin/bash
set -e

# Script to tag ECR images as Mend images for Docker Hub publishing
# Usage: ./bin/tag-ecr-images.sh <VERSION> <ECR_REGISTRY>

VERSION=$1
ECR_REGISTRY=$2

if [ -z "$VERSION" ] || [ -z "$ECR_REGISTRY" ]; then
    echo "Usage: $0 <VERSION> <ECR_REGISTRY>"
    echo ""
    echo "Parameters:"
    echo "  VERSION        - Version tag (e.g., 25.10.1)"
    echo "  ECR_REGISTRY   - ECR registry URL"
    echo ""
    echo "Example:"
    echo "  $0 25.10.1 123456789012.dkr.ecr.us-east-1.amazonaws.com"
    exit 1
fi

echo "🏷️ Tagging ECR images for Mend Hub publishing..."
echo "Version: $VERSION"
echo "ECR Registry: $ECR_REGISTRY"
echo ""

# Tag controller image
echo "Tagging controller image..."
docker tag $ECR_REGISTRY/base-repo-controller:$VERSION mend/controller:$VERSION

# Tag scanner images
echo "Tagging scanner images..."
docker tag $ECR_REGISTRY/base-repo-scanner:$VERSION mend/scanner:$VERSION

docker tag $ECR_REGISTRY/base-repo-scanner-full:$VERSION mend/scanner-full:$VERSION

docker tag $ECR_REGISTRY/base-repo-scanner-sast:$VERSION mend/scanner-sast:$VERSION

# Tag remediate image
echo "Tagging remediate image..."
docker tag $ECR_REGISTRY/base-repo-remediate:$VERSION mend/remediate:$VERSION

echo "✅ All images tagged successfully for Mend Hub!"
echo ""
echo "📋 Tagged images:"
docker images --filter="reference=mend/*" --format "table {{.Repository}}:{{.Tag}}" | head -20
