#!/bin/bash
set -e

# Script to merge version to main branch after production publish
# Usage: ./bin/merge-to-main.sh <VERSION> <IS_LATEST>

VERSION=$1
IS_LATEST=$2

if [ -z "$VERSION" ]; then
  echo "Error: No ZIP version argument provided."
  exit 1
fi

if [ -z "$IS_LATEST" ]; then
  echo "Error: No IsLatest argument provided."
  exit 1
fi

RELEASE_BRANCH="release/$VERSION"

echo "Processing Git operations for Production release"
echo "ZIP Version: $VERSION"
echo "Is Latest: $IS_LATEST"
echo "Release branch: $RELEASE_BRANCH"

# Configure Git
git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

# Mark this version as production-released.
# The CVE monitor queries these tags to determine which versions are eligible for OS refreshes,
# preventing it from promoting staging-only versions to production.
# Silently skip if the tag already exists (e.g., during CVE refresh cycles).
git tag "prod-$VERSION" 2>/dev/null || echo "Tag prod-$VERSION already exists, skipping"
git push origin "prod-$VERSION" 2>/dev/null || echo "Tag prod-$VERSION already pushed, skipping"

# If IsLatest is true, merge to main branch
if [ "$IS_LATEST" = "true" ]; then
    echo "IsLatest is true, merging changes to main branch"

    # Fetch latest changes
    git fetch origin

    # Verify release branch exists
    if ! git rev-parse --verify "origin/$RELEASE_BRANCH" >/dev/null 2>&1; then
        echo "Error: Release branch $RELEASE_BRANCH does not exist"
        exit 1
    fi

    # Checkout and update main
    git checkout main
    git pull origin main

    # Merge release branch
    git merge "origin/$RELEASE_BRANCH" --no-ff -m "feat: Merge production release $VERSION"
    git push origin main

    echo "Successfully merged release branch to main"
else
    echo "IsLatest is false, skipping merge to main branch"
fi

echo "Script completed successfully"