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
docker push "mend/base-repo-controller:$VERSION"

# Push scanner images
echo "📦 Publishing scanner images..."
docker push "mend/base-repo-scanner:$VERSION"

docker push "mend/base-repo-scanner:$VERSION-full"

docker push "mend/base-repo-scanner-sast:$VERSION"

# Push remediate image
echo "📦 Publishing remediate image..."
docker push "mend/base-repo-remediate:$VERSION"

echo ""
echo "✅ Successfully published all images to Mend Hub"
echo "📦 Published images:"
echo "  - mend/base-repo-controller:$VERSION"
echo "  - mend/base-repo-scanner:$VERSION"
echo "  - mend/base-repo-scanner-:$VERSION-full"
echo "  - mend/base-repo-scanner-sast:$VERSION"
echo "  - mend/base-repo-remediate:$VERSION"
