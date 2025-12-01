#!/bin/bash
set -e

# Script to send Slack notification for Docker images ready

ENVIRONMENT=$1
VERSION=$2
REGISTRY_URL=$3
JOB_STATUS=$4
WORKFLOW_URL=$5

if [ -z "$ENVIRONMENT" ] || [ -z "$VERSION" ] || [ -z "$REGISTRY_URL" ] || [ -z "$JOB_STATUS" ] || [ -z "$WORKFLOW_URL" ]; then
    echo "Usage: $0 <ENVIRONMENT> <VERSION> <REGISTRY_URL> <JOB_STATUS> <WORKFLOW_URL>"
    echo ""
    echo "Parameters:"
    echo "  ENVIRONMENT    - Environment (STG or Production)"
    echo "  VERSION        - Version tag (e.g., 25.10.1)"
    echo "  REGISTRY_URL   - Registry URL or 'mend' for Docker Hub"
    echo "  JOB_STATUS     - Job status (success, failure, etc.)"
    echo "  WORKFLOW_URL   - GitHub workflow run URL"
    echo ""
    echo "Note: Slack channel is determined by the webhook URL configuration"
    echo ""
    echo "Examples:"
    echo "  STG: $0 STG 25.10.1 054331651301.dkr.ecr.us-east-1.amazonaws.com success https://github.com/..."
    echo "  Prod: $0 Production 25.10.1 054331651301.dkr.ecr.us-east-1.amazonaws.com failure https://github.com/..."
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
    READY_MESSAGE="ready Images"
    IMAGES="
• \`$REGISTRY_URL/base-repo-controller:$VERSION\`
• \`$REGISTRY_URL/base-repo-scanner:$VERSION\`
• \`$REGISTRY_URL/base-repo-scanner:$VERSION-full\`
• \`$REGISTRY_URL/base-repo-scanner-sast:$VERSION\`
• \`$REGISTRY_URL/base-repo-remediate:$VERSION\`"

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
echo "Message preview:"
echo "$SLACK_MESSAGE"

# Send to Slack using webhook with enhanced formatting
if [ -n "$SLACK_WEBHOOK_URL" ]; then
    payload=$(jq -n \
        --arg text "$SLACK_MESSAGE" \
        --arg color "$COLOR" \
        --arg env "$ENVIRONMENT" \
        --arg version "$VERSION" \
        --arg status "$STATUS_MESSAGE" \
        '{text: $text, attachments: [{color: $color, fields: [{title: "Environment", value: $env, short: true}, {title: "Version", value: $version, short: true}, {title: "Status", value: $status, short: true}]}]}')

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
