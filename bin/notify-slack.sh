#!/bin/bash
set -e

# Script to send Slack notification for Docker images ready

VERSION=$1
JOB_STATUS=$2
WORKFLOW_URL=$3

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
    READY_MESSAGE="ready Images"
    IMAGES="
• \`$ECR_REGISTRY/base-repo-controller:$VERSION\`
• \`$ECR_REGISTRY/base-repo-scanner:$VERSION\`
• \`$ECR_REGISTRY/base-repo-scanner:$VERSION-full\`
• \`$ECR_REGISTRY/base-repo-scanner-sast:$VERSION\`
• \`$ECR_REGISTRY/base-repo-remediate:$VERSION\`"

    # Create success message
    SLACK_MESSAGE="🚀 * Base Images Ready*

📦 *Tag:* \`$VERSION\`
📋 *Images Published:*$IMAGES

$STATUS_EMOJI All base images for services are now $READY_MESSAGE
🔗 Workflow: <$WORKFLOW_URL|View Run>"
else
    # Create failure message
    SLACK_MESSAGE="💥 * Base Images Pipeline $STATUS_MESSAGE*

📦 *Tag:* \`$VERSION\`
$STATUS_EMOJI Pipeline failed during base images build/publish process

Please check the workflow logs for details:
🔗 Workflow: <$WORKFLOW_URL|View Run>

⚠️ Base images are NOT ready - manual intervention required"
fi

echo "Status: $JOB_STATUS"
echo "Message preview:"
echo "$SLACK_MESSAGE"

# Send to Slack using webhook with enhanced formatting
if [ -n "$SLACK_WEBHOOK_URL" ]; then
    payload=$(jq -n \
        --arg text "$SLACK_MESSAGE" \
        --arg color "$COLOR" \
        --arg version "$VERSION" \
        --arg status "$STATUS_MESSAGE" \
        '{text: $text, attachments: [{color: $color, fields: [{title: "Version", value: $version, short: true}, {title: "Status", value: $status, short: true}]}]}')

    curl -X POST -H 'Content-type: application/json' --data "$payload" "$SLACK_WEBHOOK_URL"

    if [ $? -eq 0 ]; then
        echo "✅ Slack notification sent successfully"
    else
        echo "❌ Failed to send Slack notification"
        exit 1
    fi
else
    echo "⚠️ SLACK_WEBHOOK_URL not set, skipping notification"
fi
