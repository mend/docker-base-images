#!/bin/bash
set -ex

if [ -z "$1" ]; then
  echo "Error: No release argument provided."
  exit 1
fi

if [ "$1" = "1.1.1" ]; then
  echo "Error: Default version tag provided. Please provide the correct tag"
  exit 1
fi 

RELEASE=$1
GHE_ZIP_PATH="s3://wsd-integration/pre-release/Agent-for-GitHub-Enterprise/agent-4-github-enterprise-$RELEASE.zip"


parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

echo "🧹 Cleaning up existing files to ensure fresh download..."
# Remove any existing ZIP and extracted folder to ensure fresh download
rm -f ../tmp/agent-4-github-enterprise-$RELEASE.zip
rm -rf ../tmp/agent-4-github-enterprise-$RELEASE

echo "📁 Creating tmp directory..."
mkdir -p ../tmp

echo "⬇️ Downloading fresh agent-4-github-enterprise-$RELEASE.zip from S3..."
aws s3 cp "$GHE_ZIP_PATH" ../tmp/agent-4-github-enterprise-$RELEASE.zip

if [ ! -f ../tmp/agent-4-github-enterprise-$RELEASE.zip ]; then
    echo "❌ Error: agent-4-github-enterprise-$RELEASE.zip not found after download."
    exit 1
fi

echo "📦 Extracting agent-4-github-enterprise-$RELEASE.zip..."
unzip -o ../tmp/agent-4-github-enterprise-$RELEASE.zip -d ../tmp

if [ ! -d ../tmp/agent-4-github-enterprise-$RELEASE ]; then
    echo "❌ Error: agent-4-github-enterprise-$RELEASE directory not found after extraction."
    exit 1
fi

echo "✅ Successfully downloaded and extracted agent-4-github-enterprise-$RELEASE"

echo ""
echo "🔍 Validating extracted content..."
echo "📁 Main directory structure:"
ls -la ../tmp/agent-4-github-enterprise-$RELEASE/

echo ""
echo "📄 Checking for expected Dockerfiles..."
echo "Controller Dockerfile: $([ -f ../tmp/agent-4-github-enterprise-$RELEASE/wss-ghe-app/docker/Dockerfile ] && echo "✅ Found" || echo "❌ Missing")"
echo "Scanner Dockerfile: $([ -f ../tmp/agent-4-github-enterprise-$RELEASE/wss-scanner/docker/Dockerfile ] && echo "✅ Found" || echo "❌ Missing")"
echo "Scanner Full Dockerfile: $([ -f ../tmp/agent-4-github-enterprise-$RELEASE/wss-scanner/docker/Dockerfilefull ] && echo "✅ Found" || echo "❌ Missing")"
echo "Scanner SAST Dockerfile: $([ -f ../tmp/agent-4-github-enterprise-$RELEASE/wss-scanner/docker/DockerfileSast ] && echo "✅ Found" || echo "❌ Missing")"
echo "Remediate Dockerfile: $([ -f ../tmp/agent-4-github-enterprise-$RELEASE/wss-remediate/docker/Dockerfile ] && echo "✅ Found" || echo "❌ Missing")"

echo ""
echo "🎉 Download and validation completed!"

