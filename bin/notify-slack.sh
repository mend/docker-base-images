#!/bin/bash
set -e

# Script to send Slack notification for Docker images ready
# Usage: ./bin/notify-slack.sh <ENVIRONMENT> <VERSION> <REGISTRY_TYPE> <REGISTRY_URL> <REPOSITORY> <JOB_STATUS> <WORKFLOW_URL> <SLACK_CHANNEL>

ENVIRONMENT=$1
VERSION=$2
REGISTRY_TYPE=$3
REGISTRY_URL=$4
REPOSITORY=$5
JOB_STATUS=$6
WORKFLOW_URL=$7
SLACK_CHANNEL=$8

if [ -z "$ENVIRONMENT" ] || [ -z "$VERSION" ] || [ -z "$REGISTRY_TYPE" ] || [ -z "$REGISTRY_URL" ] || [ -z "$JOB_STATUS" ] || [ -z "$WORKFLOW_URL" ] || [ -z "$SLACK_CHANNEL" ]; then
    echo "Usage: $0 <ENVIRONMENT> <VERSION> <REGISTRY_TYPE> <REGISTRY_URL> <REPOSITORY> <JOB_STATUS> <WORKFLOW_URL> <SLACK_CHANNEL>"
    echo ""
    echo "Parameters:"
    echo "  ENVIRONMENT    - Environment (STG or Production)"
    echo "  VERSION        - Version tag (e.g., 25.10.1)"
    echo "  REGISTRY_TYPE  - Type of registry (ECR or DockerHub)"
    echo "  REGISTRY_URL   - Registry URL or 'mend' for Docker Hub"
    echo "  REPOSITORY     - Repository name (can be empty for DockerHub)"
    echo "  JOB_STATUS     - Job status (success, failure, etc.)"
    echo "  WORKFLOW_URL   - GitHub workflow run URL"
    echo "  SLACK_CHANNEL  - Slack channel (e.g., #base-images-stg, #base-images-prod)"
    echo ""
    echo "Examples:"
    echo "  STG: $0 STG 25.10.1 ECR 123456789012.dkr.ecr.us-east-1.amazonaws.com stg-ghe-base-images success https://github.com/... #base-images-stg"
    echo "  Prod: $0 Production 25.10.1 DockerHub mend '' success https://github.com/... #base-images-prod"
    exit 1
fi

# Special handling for DockerHub - repository can be empty
if [ "$REGISTRY_TYPE" = "ECR" ] && [ -z "$REPOSITORY" ]; then
    echo "Error: Repository parameter is required for ECR registry type"
    exit 1
fi

# Determine status emoji and message
if [ "$JOB_STATUS" = "success" ]; then
    STATUS_EMOJI="✅"
    STATUS_MESSAGE="SUCCESS"
    COLOR="good"
elif [ "$JOB_STATUS" = "failure" ]; then
    STATUS_EMOJI="❌"
    STATUS_MESSAGE="FAILED"
    COLOR="danger"
else
    STATUS_EMOJI="⚠️"
    STATUS_MESSAGE="COMPLETED"
    COLOR="warning"
fi

# Build image list and status message based on registry type and job status
if [ "$JOB_STATUS" = "success" ]; then
    if [ "$REGISTRY_TYPE" = "ECR" ]; then
        IMAGE_PREFIX="$REGISTRY_URL/$REPOSITORY"
        READY_MESSAGE="ready in ECR for testing"
        IMAGES="
• \`$IMAGE_PREFIX:$VERSION\`
• \`$IMAGE_PREFIX/controller:$VERSION\`
• \`$IMAGE_PREFIX/scanner:$VERSION\`
• \`$IMAGE_PREFIX/scanner-full:$VERSION\`
• \`$IMAGE_PREFIX/scanner-sast:$VERSION\`
• \`$IMAGE_PREFIX/remediate:$VERSION\`"
    else
        IMAGE_PREFIX="$REGISTRY_URL"
        READY_MESSAGE="ready on Mend Hub"
        IMAGES="
• \`$IMAGE_PREFIX/base-image:$VERSION\`
• \`$IMAGE_PREFIX/controller:$VERSION\`
• \`$IMAGE_PREFIX/scanner:$VERSION\`
• \`$IMAGE_PREFIX/scanner-full:$VERSION\`
• \`$IMAGE_PREFIX/scanner-sast:$VERSION\`
• \`$IMAGE_PREFIX/remediate:$VERSION\`"
    fi

    # Create success message
    SLACK_MESSAGE="🚀 *$ENVIRONMENT Base Images Ready*

📦 *Tag:* \`$VERSION\`
📋 *Images Published:*$IMAGES

$STATUS_EMOJI All base images for services are now $READY_MESSAGE
🔗 Workflow: <$WORKFLOW_URL|View Run>"
else
    # Create failure message
    SLACK_MESSAGE="💥 *$ENVIRONMENT Base Images Pipeline $STATUS_MESSAGE*

📦 *Tag:* \`$VERSION\`
$STATUS_EMOJI Pipeline failed during $ENVIRONMENT base images build/publish process

Please check the workflow logs for details:
🔗 Workflow: <$WORKFLOW_URL|View Run>

⚠️ Base images are NOT ready - manual intervention required"
fi

echo "Sending Slack notification for $ENVIRONMENT environment..."
echo "Status: $JOB_STATUS"
echo "Channel: $SLACK_CHANNEL"
echo "Message preview:"
echo "$SLACK_MESSAGE"

# Send to Slack using webhook with enhanced formatting
if [ -n "$SLACK_WEBHOOK_URL" ]; then
    local payload=$(jq -n \
        --arg channel "$SLACK_CHANNEL" \
        --arg text "$SLACK_MESSAGE" \
        --arg color "$COLOR" \
        --arg env "$ENVIRONMENT" \
        --arg version "$VERSION" \
        --arg status "$STATUS_MESSAGE" \
        '{channel: $channel, text: $text, attachments: [{color: $color, fields: [{title: "Environment", value: $env, short: true}, {title: "Version", value: $version, short: true}, {title: "Status", value: $status, short: true}]}]}')

    curl -X POST -H 'Content-type: application/json' --data "$payload" "$SLACK_WEBHOOK_URL"

    if [ $? -eq 0 ]; then
        echo "✅ Slack notification sent successfully to $SLACK_CHANNEL"
    else
        echo "❌ Failed to send Slack notification"
        exit 1
    fi
else
    echo "⚠️ SLACK_WEBHOOK_URL not set, skipping notification"
fi
