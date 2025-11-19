#!/bin/bash
set -e

# Script to publish all Mend images to Docker Hub (Mend Hub)
# Usage: ./bin/publish-to-mend-hub.sh <VERSION>

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Usage: $0 <VERSION>"
    echo ""
    echo "Parameters:"
    echo "  VERSION - Version tag (e.g., 25.10.1)"
    echo ""
    echo "Example:"
    echo "  $0 25.10.1"
    echo ""
    echo "Note: Ensure you are logged in to Docker Hub before running this script"
    exit 1
fi

echo "🚀 Publishing all images to Mend Hub (Docker Hub)..."
echo "Version: $VERSION"
echo ""

# Push controller image
echo "📦 Publishing controller image..."
docker push mend/controller:$VERSION

# Push scanner images
echo "📦 Publishing scanner images..."
docker push mend/scanner:$VERSION

docker push mend/scanner-full:$VERSION

docker push mend/scanner-sast:$VERSION

# Push remediate image
echo "📦 Publishing remediate image..."
docker push mend/remediate:$VERSION

echo ""
echo "✅ Successfully published all images to Mend Hub"
echo "📦 Published images:"
echo "  - mend/controller:$VERSION"
echo "  - mend/scanner:$VERSION"
echo "  - mend/scanner-full:$VERSION"
echo "  - mend/scanner-sast:$VERSION"
echo "  - mend/remediate:$VERSION"
