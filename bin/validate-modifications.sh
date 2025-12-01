#!/bin/bash
set -ex

# Function to validate Docker file modifications were applied correctly
validate_dockerfile_modifications() {
    local dockerfile=$1
    local config_name=$2
    local config_file="config/${config_name}-modifications.txt"

    if [ ! -f "$config_file" ] || [ ! -s "$config_file" ]; then
        echo "✅ No modifications configured for $dockerfile - skipping validation"
        return 0
    fi

    echo "🔍 Validating modifications applied to $dockerfile"
    local validation_failed=false

    # Read each command from the config file and validate it was applied
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

        # Parse command format: ACTION:PATTERN:REPLACEMENT
        IFS=':' read -r action pattern replacement <<< "$line"

        case "$action" in
            "COMMENT"|"COMMENT_BLOCK")
                echo "  Checking that pattern '$pattern' is commented out..."

                # Check if lines matching the pattern are now commented
                if grep -q "^[[:space:]]*[^#]*${pattern}" "$dockerfile" 2>/dev/null; then
                    echo "  ❌ VALIDATION FAILED: Found uncommented lines matching '$pattern'"
                    echo "     Uncommented lines found:"
                    grep -n "^[[:space:]]*[^#]*${pattern}" "$dockerfile" | head -3
                    validation_failed=true
                else
                    # Check if we have commented versions of the pattern
                    if grep -q "^[[:space:]]*#.*${pattern}" "$dockerfile" 2>/dev/null; then
                        echo "  ✅ Pattern '$pattern' is properly commented out"
                    else
                        echo "  ⚠️  Warning: Pattern '$pattern' not found in file (may have been already commented or not present)"
                    fi
                fi
                ;;
            "REMOVE")
                echo "  Checking that pattern '$pattern' was removed..."

                if grep -q "${pattern}" "$dockerfile" 2>/dev/null; then
                    echo "  ❌ VALIDATION FAILED: Pattern '$pattern' still exists in file"
                    echo "     Lines still containing pattern:"
                    grep -n "${pattern}" "$dockerfile" | head -3
                    validation_failed=true
                else
                    echo "  ✅ Pattern '$pattern' successfully removed"
                fi
                ;;
            "REPLACE")
                echo "  Checking that replacement was applied for pattern '$pattern'..."

                # Check if old pattern still exists
                if grep -q "^[[:space:]]*${pattern}[[:space:]]*$" "$dockerfile" 2>/dev/null; then
                    echo "  ❌ VALIDATION FAILED: Original pattern '$pattern' still exists"
                    validation_failed=true
                elif grep -q "${replacement}" "$dockerfile" 2>/dev/null; then
                    echo "  ✅ Replacement successfully applied"
                else
                    echo "  ❌ VALIDATION FAILED: Neither original pattern nor replacement found"
                    validation_failed=true
                fi
                ;;
            "ADD_AFTER"|"ADD_BEFORE")
                echo "  Checking that line was added: '$replacement'..."

                if grep -q "${replacement}" "$dockerfile" 2>/dev/null; then
                    echo "  ✅ Line successfully added"
                else
                    echo "  ❌ VALIDATION FAILED: Added line not found in file"
                    validation_failed=true
                fi
                ;;
        esac

    done < "$config_file"

    if [ "$validation_failed" = true ]; then
        echo "❌ VALIDATION FAILED for $dockerfile"
        echo "   Some modifications were not applied correctly!"
        return 1
    else
        echo "✅ All modifications validated successfully for $dockerfile"
        return 0
    fi
}

# Function to validate all Docker files in the pipeline
validate_all_modifications() {
    echo ""
    echo "🔍 Starting validation of all Docker file modifications..."
    echo "================================================================"

    local overall_success=true

    # Validate controller modifications
    if ! validate_dockerfile_modifications "repo-integrations/controller/Dockerfile" "controller"; then
        overall_success=false
    fi

    echo ""

    # Validate scanner modifications
    if ! validate_dockerfile_modifications "repo-integrations/scanner/Dockerfile" "scanner"; then
        overall_success=false
    fi

    echo ""

    if ! validate_dockerfile_modifications "repo-integrations/scanner/Dockerfile.full" "scanner"; then
        overall_success=false
    fi

    echo ""

    # Validate SAST scanner modifications
    if ! validate_dockerfile_modifications "repo-integrations/scanner/DockerfileSast" "scanner"; then
        overall_success=false
    fi

    echo ""

    # Validate remediate modifications
    if ! validate_dockerfile_modifications "repo-integrations/remediate/Dockerfile" "remediate"; then
        overall_success=false
    fi

    echo ""
    echo "================================================================"

    if [ "$overall_success" = true ]; then
        echo "🎉 ALL DOCKER FILE MODIFICATIONS VALIDATED SUCCESSFULLY!"
        echo "   Your pipeline modifications have been applied correctly."
        return 0
    else
        echo "💥 PIPELINE VALIDATION FAILED!"
        echo "   Some Docker file modifications were not applied correctly."
        echo "   Please review the errors above and check your modification configurations."
        return 1
    fi
}

# If script is run directly, validate all modifications
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    validate_all_modifications
fi
