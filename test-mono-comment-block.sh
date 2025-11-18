#!/bin/bash
set -e

echo "=== Testing COMMENT_BLOCK on Mono Installation ==="
echo ""

# Create test directory
mkdir -p test-mono-block

# Create a test Dockerfile with the mono installation uncommented (as it would appear in source)
cat > test-mono-block/test-dockerfile << 'EOF'
USER 0

#### Install Mono
RUN apt-get update && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
    apt-get install -y --no-install-recommends apt-transport-https ca-certificates && \
    echo "deb https://download.mono-project.com/repo/ubuntu bionic main" | tee /etc/apt/sources.list.d/mono-official-stable.list && \
    apt-get update && \
    apt-get install -y mono-devel && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

### Install Nuget CLI
RUN apt-get update && \
	apt-get install nuget

## Install Paket
ENV PAKET_HOME=${USER_HOME}/.dotnet/tools
ENV PATH="${PATH}:${PAKET_HOME}"
RUN dotnet tool install Paket --version 7.2.1 --tool-path ${PAKET_HOME}

# Install Swift (including SPM)
ARG SWIFT_VERSION=5.10.1
RUN install-tool swift
EOF

# Create configuration to comment out the mono installation block
cat > test-mono-block/mono-config.txt << 'EOF'
# Comment out the entire mono installation block starting from "Install Mono"
COMMENT_BLOCK:Install Mono
EOF

echo "=== BEFORE modification ==="
echo "Original mono installation block:"
cat -n test-mono-block/test-dockerfile
echo ""

echo "=== Applying COMMENT_BLOCK modification ==="
echo "Configuration:"
cat test-mono-block/mono-config.txt
echo ""

# Apply the modification
./bin/modify-dockerfile.sh test-mono-block/test-dockerfile test-mono-block/mono-config.txt

echo "=== AFTER modification ==="
echo "Result - Entire mono block should be commented out:"
cat -n test-mono-block/test-dockerfile
echo ""

echo "=== Verification ==="
echo "Checking that mono lines are commented while nuget and other lines remain unchanged:"
echo ""
echo "Mono installation lines (should all be commented):"
grep -n "mono\|apt-key\|mono-devel" test-mono-block/test-dockerfile || echo "All mono lines are commented out"
echo ""
echo "Nuget installation lines (should remain unchanged):"
grep -n "Nuget\|apt-get install nuget" test-mono-block/test-dockerfile || echo "Nuget lines not found"
echo ""
echo "Other installations (should remain unchanged):"
grep -n "Paket\|Swift" test-mono-block/test-dockerfile || echo "Other installation lines not found"

echo ""
echo "=== Summary ==="
echo "✅ Test completed!"
echo "The COMMENT_BLOCK action should have:"
echo "1. Found the line containing 'Install Mono'"
echo "2. Located the RUN block that follows"
echo "3. Commented out the entire multi-line RUN command"
echo "4. Left nuget and other installations untouched"

# Cleanup
echo ""
echo "Cleaning up test files..."
rm -rf test-mono-block
