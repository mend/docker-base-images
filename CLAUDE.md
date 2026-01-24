# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Working Principles

**Objectivity and Honesty**: Never tell me what I want to hear. I want you to look at things objectively, contradict me when needed. If you think otherwise, go with your strong opinion.

**Security and Best Practices**: You are a senior software developer with DevOps and security experience. Apply these principles:
- **Never log or expose secrets**: Always mask private or sensitive data (API keys, tokens, credentials, internal URLs)
- **Public Repository Awareness**: Assume this repository is publicly accessible. Never commit sensitive information or suggest solutions that expose internal systems
- **SOLID Principles**: Keep methods and classes focused and maintainable. Avoid very long and complex methods/classes when they can be split based on SOLID principles
- **Code Reuse**: Define global variables when needed and extract reusable functions to avoid duplication
- **Validation First**: Always validate inputs, especially in scripts that modify files or deploy infrastructure

## Overview

This repository contains Docker base images for Mend.io products (controller, scanner, remediate services). These base images are published to Docker Hub and contain only open-source tools, no proprietary Mend logic. The images are built from upstream Mend product Dockerfiles that are truncated at a marker comment `# END OF BASE IMAGE`.

## Architecture

### Core Pipeline Flow

1. **Extract Base Images**: Source Dockerfiles from `tmp/agent-4-github-enterprise-{VERSION}/` are truncated at the `# END OF BASE IMAGE` marker to create base images
2. **Apply Modifications**: Configuration-driven modifications are applied to Dockerfiles via `config/*-modifications.txt` files
3. **Build**: Docker images are built with multiple language runtime versions (Java 8/11/17/21, Python 2.7/3.6-3.13, Node 24, etc.)
4. **Validate**: Automated validation ensures modifications were applied correctly
5. **Publish**: Images are pushed to Docker Hub (Mend Hub) or ECR

### Directory Structure

- `repo-integrations/`: Contains generated Dockerfiles for each service
  - `controller/Dockerfile`: Controller service base image
  - `scanner/Dockerfile`: SCA scanner base image
  - `scanner/Dockerfile.full`: Full SCA scanner with all tools
  - `scanner/DockerfileSast`: SAST scanner base image
  - `remediate/Dockerfile`: Remediate service base image
- `bin/`: Shell scripts for the build/publish pipeline
- `config/`: Modification configuration files for customizing Dockerfiles

### Dockerfile Modification System

The repository uses a custom modification system to customize Dockerfiles:

**Configuration Files** (`config/*-modifications.txt`):
- Format: `ACTION:PATTERN:REPLACEMENT`
- Actions:
  - `COMMENT`: Comment out single lines matching pattern
  - `COMMENT_BLOCK`: Comment out entire multi-line RUN blocks (searches for pattern in comments or RUN commands)
  - `REMOVE`: Delete lines matching pattern
  - `REPLACE`: Replace entire line with new content
  - `ADD_AFTER`: Insert line after matching pattern
  - `ADD_BEFORE`: Insert line before matching pattern

**Example from `config/scanner-modifications.txt`**:
```
COMMENT_BLOCK:Install Mono
COMMENT_BLOCK:Install Nuget CLI
COMMENT:apt-get install.*nuget
```

### Tool Installation Pattern

Base images use containerbase for consistent tool installation:
```dockerfile
ARG TOOL_VERSION=x.y.z
RUN install-tool toolname
```

Multiple versions can be installed; the last one becomes the default. See `repo-integrations/scanner/Dockerfile` for examples with Java, Python, Gradle, etc.

## Common Commands

### Build Images Locally
```bash
# Build all images with a version tag and registry prefix
./bin/build.sh <VERSION> <REGISTRY_PREFIX> [COPY_VERSIONS_JSON]

# Example for ECR testing
./bin/build.sh 25.10.1 054331651301.dkr.ecr.us-east-1.amazonaws.com
```

### Copy/Extract Dockerfiles from Upstream
```bash
# Extract base images from upstream Mend product releases
./bin/copy.sh <VERSION> [COPY_VERSIONS_JSON]

# Example
./bin/copy.sh 25.10.1 true
```
This script:
1. Extracts Dockerfiles from `tmp/agent-4-github-enterprise-{VERSION}/`
2. Truncates at `# END OF BASE IMAGE` marker
3. Applies modifications from `config/*-modifications.txt`
4. Optionally appends version scanning script support

### Modify Dockerfiles
```bash
# Apply modifications to a Dockerfile using a config file
./bin/modify-dockerfile.sh <DOCKERFILE> <CONFIG_FILE>

# Example
./bin/modify-dockerfile.sh repo-integrations/scanner/Dockerfile config/scanner-modifications.txt
```

### Validate Modifications
```bash
# Validate that all modifications were applied correctly
./bin/validate-modifications.sh
```
This checks each Dockerfile against its configuration to ensure:
- Patterns marked for COMMENT/COMMENT_BLOCK are commented
- Patterns marked for REMOVE are removed
- Patterns marked for REPLACE were replaced

### Test Modification Behavior
```bash
# Test COMMENT_BLOCK functionality on mono installation
./test-mono-comment-block.sh
```

### Generate Version Metadata
```bash
# Generate JSON of installed tool versions from a Dockerfile
./generate_versions_json.sh <DOCKERFILE_PATH>
```
Outputs JSON mapping tool names to their installed versions.

### Publish Images
```bash
# Publish to Docker Hub (production)
./bin/prod-publish.sh <VERSION>

# Publish to Mend Hub
./bin/publish-to-mend-hub.sh <VERSION>
```

### Download/Tag ECR Images
```bash
# Download images from ECR
./bin/download-ecr-images.sh <VERSION> <ECR_REGISTRY>

# Tag ECR images for Mend Hub
./bin/tag-ecr-images.sh <VERSION> <ECR_REGISTRY>
```

## GitHub Actions Workflows

### Production Release
**Workflow**: `prod-from-version-build-push-tag-base-image.yaml`
- Triggered manually with version input
- Downloads pre-built images from ECR
- Tags and publishes to Mend Hub (Docker Hub)
- Optionally merges release branch to main

### Staging Release
**Workflow**: `stg-from-version-build-push-tag-base-image.yaml`
- Similar to production but for staging environment

## Key Constraints

1. **Base Image Marker**: All source Dockerfiles must have `# END OF BASE IMAGE` comment to mark truncation point
2. **Open Source Only**: Base images must contain only open-source tools, no proprietary Mend code
3. **Tool Versions**: Last installed version of a tool becomes the default (e.g., Java 17 is default because it's installed last)
4. **CVE Annotations**: Dockerfiles contain CVE comment blocks documenting known vulnerabilities in specific versions
5. **Modification Validation**: All modifications must pass validation checks before images can be published

## Development Workflow

When adding or updating tools:
1. Modify source Dockerfiles in `repo-integrations/` directly, OR
2. Update `config/*-modifications.txt` to apply transformations
3. Run `./bin/validate-modifications.sh` to ensure changes are correct
4. Test locally with `./bin/build.sh`
5. Use GitHub Actions for official releases

## Notes

- The repository uses Renovate for automated dependency updates (see `renovate:` comments in Dockerfiles)
- `containerbase` provides the `install-tool` command and user/directory setup
- Environment variables like `MEND_JAVA` point to specific tool versions for Mend products
- The `generate_versions_json.sh` script creates metadata about installed tools for runtime discovery
