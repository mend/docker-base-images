#!/bin/bash
set -e

# Script to merge version to main branch after production publish
# Usage: ./bin/merge-to-main.sh <VERSION>

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Usage: $0 <VERSION>"
    echo ""
    echo "Parameters:"
    echo "  VERSION - Version tag or branch (e.g., 25.10.1 or release/25.10.1)"
    echo ""
    echo "Example:"
    echo "  $0 25.10.1"
    echo "  $0 release/25.10.1"
    exit 1
fi

echo "🔄 Merging changes into main branch..."

# Configure Git
git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

echo "📋 Processing version: $VERSION"

# Check if it's a release branch pattern
if [[ "$VERSION" =~ ^release/.* ]]; then
    echo "📋 Detected release branch: $VERSION"
    git checkout main
    git pull origin main
    git merge "origin/$VERSION" --commit --no-edit -m "Merge $VERSION into main after production publish"
    git push origin main
    echo "✅ Successfully merged $VERSION into main"
else
    echo "📋 Detected tag or other branch: $VERSION"
    echo "ℹ️ For tags, no merge is needed as they represent finalized code"
    echo "ℹ️ For feature branches, manual merge is recommended"
fi

echo "🎉 Merge process completed!"
