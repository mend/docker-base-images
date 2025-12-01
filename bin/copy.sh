#!/bin/bash
set -ex

# Source validation functions
source ./bin/validate-modifications.sh


append_scanner_script_support() {
    local target_file=$1
    
    cat >> "$target_file" << EOF


# Temporarily copying the current Dockerfile and the version scanner script to generate the installed-versions.json file.
COPY generate_versions_json.sh /usr/local/bin/generate_versions_json.sh
ARG THIS_DOCKERFILE_NAME=$target_file
COPY \${THIS_DOCKERFILE_NAME} /tmp/target-dockerfile
RUN chmod +x /usr/local/bin/generate_versions_json.sh \\
  && mkdir "\${USER_HOME}/.mend" \\
  && /usr/local/bin/generate_versions_json.sh /tmp/target-dockerfile \\
     > "\${USER_HOME}/.mend/installed-versions.json" \\
  && rm /tmp/target-dockerfile && rm /usr/local/bin/generate_versions_json.sh 
EOF
}

# Function to apply Docker file modifications
apply_dockerfile_modifications() {
    local dockerfile=$1
    local config_name=$2
    local config_file="config/${config_name}-modifications.txt"

    if [ -f "$config_file" ] && [ -s "$config_file" ]; then
        echo "Applying modifications to $dockerfile using $config_file"
        ./bin/modify-dockerfile.sh "$dockerfile" "$config_file"
    else
        echo "No modifications configured for $dockerfile (config: $config_file)"
    fi
}

RELEASE=$1
COPY_VERSIONS_JSON=$2

if [ -z "$RELEASE" ]; then
  echo "Error: No release argument provided."
  exit 1
fi

if [ "$RELEASE" = "1.1.1" ]; then
  echo "Error: Default version tag provided. Please provide the correct tag"
  exit 1
fi

echo "release arg: $RELEASE"
echo "COPY_VERSIONS_JSON arg: $COPY_VERSIONS_JSON"

echo ""
echo "🔍 Debugging downloaded Dockerfiles content..."

# ================================
# CONTROLLER SERVICE PROCESSING
# ================================
echo "🎯 Processing Controller Service Dockerfile..."
appdockerfile=tmp/agent-4-github-enterprise-$RELEASE/wss-ghe-app/docker/Dockerfile

if [ ! -f $appdockerfile ]; then
  echo "Error: $appdockerfile not found."
  exit 1
fi

echo "📄 Controller Dockerfile first 10 lines:"
head -10 "$appdockerfile"
echo "..."
echo "📄 Controller Dockerfile last 10 lines:"
tail -10 "$appdockerfile"
echo "🔍 Base image marker check: $(grep -c '# END OF BASE IMAGE' "$appdockerfile" || echo "0") occurrences found"
echo ""

echo "🔍 Checking controller Dockerfile for base image marker..."
if ! grep -q "# END OF BASE IMAGE" "$appdockerfile"; then
  echo "❌ ERROR: '# END OF BASE IMAGE' marker not found in $appdockerfile"
  echo "📄 First 20 lines of source file:"
  head -20 "$appdockerfile"
  exit 1
fi

echo "✅ Base image marker found, truncating controller Dockerfile..."
sed '/# END OF BASE IMAGE/ q' $appdockerfile > repo-integrations/controller/Dockerfile

echo "🔍 Validating controller Dockerfile truncation..."
if ! grep -q "# END OF BASE IMAGE" repo-integrations/controller/Dockerfile; then
  echo "❌ ERROR: Truncation failed for controller Dockerfile"
  exit 1
fi
echo "✅ Controller Dockerfile successfully truncated at base image marker"

# ================================
# SAST SCANNER SERVICE PROCESSING
# ================================
echo "🎯 Processing SAST Scanner Service Dockerfile..."
sastScannerDockerfile=tmp/agent-4-github-enterprise-$RELEASE/wss-scanner/docker/DockerfileSast

if [ ! -f $sastScannerDockerfile ]; then
  echo "Error: $sastScannerDockerfile not found."
  exit 1
fi

echo "📄 SAST Scanner Dockerfile first 15 lines:"
head -15 "$sastScannerDockerfile"
echo "..."
echo "📄 SAST Scanner Dockerfile last 10 lines:"
tail -10 "$sastScannerDockerfile"
echo "🔍 Base image marker check: $(grep -c '# END OF BASE IMAGE' "$sastScannerDockerfile" || echo "0") occurrences found"
echo ""

echo "🔍 Checking SAST scanner Dockerfile for base image marker..."
if ! grep -q "# END OF BASE IMAGE" "$sastScannerDockerfile"; then
  echo "❌ ERROR: '# END OF BASE IMAGE' marker not found in $sastScannerDockerfile"
  echo "📄 First 40 lines of source file:"
  head -40 "$sastScannerDockerfile"
  exit 1
fi

echo "✅ Base image marker found, truncating SAST Dockerfile..."
sed '/# END OF BASE IMAGE/ q' $sastScannerDockerfile > repo-integrations/scanner/DockerfileSast

echo "🔍 Validating SAST Dockerfile truncation..."
if ! grep -q "# END OF BASE IMAGE" repo-integrations/scanner/DockerfileSast; then
  echo "❌ ERROR: Truncation failed for SAST Dockerfile"
  exit 1
fi
echo "✅ SAST Dockerfile successfully truncated at base image marker"

# ================================
# SCA SCANNER SERVICE PROCESSING
# ================================
echo "🎯 Processing SCA Scanner Service Dockerfile..."
scaScannerDockerfile=tmp/agent-4-github-enterprise-$RELEASE/wss-scanner/docker/Dockerfile

if [ ! -f $scaScannerDockerfile ]; then
  echo "Error: $scaScannerDockerfile not found."
  exit 1
fi

echo "📄 SCA Scanner Dockerfile first 10 lines:"
head -10 "$scaScannerDockerfile"
echo "..."
echo "📄 SCA Scanner Dockerfile last 10 lines:"
tail -10 "$scaScannerDockerfile"
echo "🔍 Base image marker check: $(grep -c '# END OF BASE IMAGE' "$scaScannerDockerfile" || echo "0") occurrences found"
echo ""

echo "🔍 Checking SCA scanner Dockerfile for base image marker..."
if ! grep -q "# END OF BASE IMAGE" "$scaScannerDockerfile"; then
  echo "❌ ERROR: '# END OF BASE IMAGE' marker not found in $scaScannerDockerfile"
  echo "📄 First 20 lines of source file:"
  head -20 "$scaScannerDockerfile"
  exit 1
fi

echo "✅ Base image marker found, truncating SCA Dockerfile..."
sed '/# END OF BASE IMAGE/ q' $scaScannerDockerfile > repo-integrations/scanner/Dockerfile

echo "🔍 Validating SCA Dockerfile truncation..."
if ! grep -q "# END OF BASE IMAGE" repo-integrations/scanner/Dockerfile; then
  echo "❌ ERROR: Truncation failed for SCA Dockerfile"
  exit 1
fi
echo "✅ SCA Dockerfile successfully truncated at base image marker"
apply_dockerfile_modifications "repo-integrations/scanner/Dockerfile" "scanner"
if [ "$COPY_VERSIONS_JSON" = true ]; then
    append_scanner_script_support "repo-integrations/scanner/Dockerfile"
fi

# ================================
# SCA SCANNER FULL SERVICE PROCESSING
# ================================
echo "🎯 Processing SCA Scanner Full Service Dockerfile..."
scaScannerDockerfilefull=tmp/agent-4-github-enterprise-$RELEASE/wss-scanner/docker/Dockerfilefull

if [ ! -f $scaScannerDockerfilefull ]; then
  echo "Error: $scaScannerDockerfilefull not found."
  exit 1
fi

echo "📄 SCA Scanner Full Dockerfile first 10 lines:"
head -10 "$scaScannerDockerfilefull"
echo "..."
echo "📄 SCA Scanner Full Dockerfile last 10 lines:"
tail -10 "$scaScannerDockerfilefull"
echo "🔍 Base image marker check: $(grep -c '# END OF BASE IMAGE' "$scaScannerDockerfilefull" || echo "0") occurrences found"
echo ""

echo "🔍 Checking SCA scanner full Dockerfile for base image marker..."
if ! grep -q "# END OF BASE IMAGE" "$scaScannerDockerfilefull"; then
  echo "❌ ERROR: '# END OF BASE IMAGE' marker not found in $scaScannerDockerfilefull"
  echo "📄 First 20 lines of source file:"
  head -20 "$scaScannerDockerfilefull"
  exit 1
fi

echo "✅ Base image marker found, truncating SCA full Dockerfile..."
sed '/# END OF BASE IMAGE/ q' $scaScannerDockerfilefull > repo-integrations/scanner/Dockerfile.full

echo "🔍 Validating SCA full Dockerfile truncation..."
if ! grep -q "# END OF BASE IMAGE" repo-integrations/scanner/Dockerfile.full; then
  echo "❌ ERROR: Truncation failed for SCA full Dockerfile"
  exit 1
fi
echo "✅ SCA full Dockerfile successfully truncated at base image marker"

apply_dockerfile_modifications "repo-integrations/scanner/Dockerfile.full" "scanner"
if [ "$COPY_VERSIONS_JSON" = true ]; then
    append_scanner_script_support "repo-integrations/scanner/Dockerfile.full"
fi

# ================================
# REMEDIATE SERVICE PROCESSING
# ================================
echo "🎯 Processing Remediate Service Dockerfile..."
remediateDockerfile=tmp/agent-4-github-enterprise-$RELEASE/wss-remediate/docker/Dockerfile

if [ ! -f $remediateDockerfile ]; then
  echo "Error: $remediateDockerfile not found."
  exit 1
fi

echo "📄 Remediate Dockerfile first 10 lines:"
head -10 "$remediateDockerfile"
echo "..."
echo "📄 Remediate Dockerfile last 10 lines:"
tail -10 "$remediateDockerfile"
echo "🔍 Base image marker check: $(grep -c '# END OF BASE IMAGE' "$remediateDockerfile" || echo "0") occurrences found"
echo ""

echo "🔍 Checking remediate Dockerfile for base image marker..."
if ! grep -q "# END OF BASE IMAGE" "$remediateDockerfile"; then
  echo "❌ ERROR: '# END OF BASE IMAGE' marker not found in $remediateDockerfile"
  echo "📄 First 20 lines of source file:"
  head -20 "$remediateDockerfile"
  exit 1
fi

echo "✅ Base image marker found, truncating remediate Dockerfile..."
sed '/# END OF BASE IMAGE/ q' $remediateDockerfile > repo-integrations/remediate/Dockerfile

echo "🔍 Validating remediate Dockerfile truncation..."
if ! grep -q "# END OF BASE IMAGE" repo-integrations/remediate/Dockerfile; then
  echo "❌ ERROR: Truncation failed for remediate Dockerfile"
  exit 1
fi
echo "✅ Remediate Dockerfile successfully truncated at base image marker"

apply_dockerfile_modifications "repo-integrations/scanner/DockerfileSast" "scanner"
echo "✅ Remediate Dockerfile successfully truncated at base image marker"

echo "🔍 Validating all Docker file modifications..."
# Validate that all modifications were applied correctly
if ! validate_all_modifications; then
    echo ""
    echo "💥 PIPELINE FAILED: Docker file modifications validation failed!"
    echo "Please check the validation errors above and fix the modification configurations."
    exit 1
fi

echo ""
echo "🎉 Pipeline completed successfully with all modifications validated!"

echo ""
echo "🔍 Final validation - Generated Dockerfile content:"
echo "=========================================="
echo "📄 Generated Controller Dockerfile (first 10 lines):"
head -10 repo-integrations/controller/Dockerfile
echo "..."
echo "📄 Generated Controller Dockerfile (last 5 lines):"
tail -5 repo-integrations/controller/Dockerfile
echo ""
echo "📄 Generated SAST Scanner Dockerfile (first 10 lines):"
head -10 repo-integrations/scanner/DockerfileSast
echo "..."
echo "📄 Generated SAST Scanner Dockerfile (last 5 lines):"
tail -5 repo-integrations/scanner/DockerfileSast
echo "=========================================="

