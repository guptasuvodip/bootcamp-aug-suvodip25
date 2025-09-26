#!/bin/bash

# This script checks if a file/directory has correct permissions and ownership

EXIT_CODE=0

usage() {
    echo "Usage: $0 <file_or_dir_path> <expected_permission>"
}

validate_arguments() {
    if [ $# -ne 2 ]; then
        usage
        exit 3
    fi

    FILE_PATH="$1"
    EXPECTED_PERMISSION="$2"
}

validate_file_exists() {
    if [ ! -e "$FILE_PATH" ]; then
        echo "❌ Error: Path '$FILE_PATH' does not exist."
        exit 2
    fi
}

validate_format() {
    if ! echo "$EXPECTED_PERMISSION" | grep -qE '^[0-7]{3}$'; then
        echo "Invalid permission format: '$EXPECTED_PERMISSION'"
        exit 3
    fi
}

gather_file_info() {
    CURRENT_USER=$(whoami)
    ACTUAL_PERMISSION=$(stat -c %a "$FILE_PATH" 2>/dev/null)
    FILE_OWNER=$(stat -c %U "$FILE_PATH" 2>/dev/null)

    if [ -z "$ACTUAL_PERMISSION" ] || [ -z "$FILE_OWNER" ]; then
        echo "❌ Error: Unable to retrieve file information for '$FILE_PATH'"
        exit 1
    fi
}

validate_permissions_match() {
    echo "----------------------------------------"
    echo "Checking permissions for: $FILE_PATH :-"

    if [ "$ACTUAL_PERMISSION" = "$EXPECTED_PERMISSION" ]; then
        echo "✅ $FILE_PATH has correct permissions ($ACTUAL_PERMISSION)"
    else
        echo "❌ $FILE_PATH has permissions $ACTUAL_PERMISSION (expected: $EXPECTED_PERMISSION)"
        EXIT_CODE=1
    fi
}

validate_file_ownership() {
    if [ "$FILE_OWNER" = "$CURRENT_USER" ]; then
        echo "✅ File ownership is secure (owned by $CURRENT_USER)"
    else
        echo "❌ File owned by different user (actual owner: $FILE_OWNER, current user: $CURRENT_USER)"
        EXIT_CODE=1
    fi
}

perform_security_analysis() {
    echo "----------------------------------------"
    echo "Security Analysis:"

    others_perm=${ACTUAL_PERMISSION:2:1}

    # Check world writable in a simplified manner
    if [[ "$others_perm" == "2" || "$others_perm" == "3" || "$others_perm" == "6" || "$others_perm" == "7" ]]; then
        echo "⚠️  WARNING: File is world-writable! This is a security risk."
        EXIT_CODE=1
    else
        echo "✅ File is not world-writable"
    fi

    # Check world readable in a simplified manner
    if [[ "$others_perm" == "4" || "$others_perm" == "5" || "$others_perm" == "6" || "$others_perm" == "7" ]]; then
        echo "ℹ️  File is world-readable (may be intentional)"
    else
        echo "✅ File is not world-readable"
    fi
}

validate_directory_permissions() {
    if [ -d "$FILE_PATH" ]; then
        echo "ℹ️  This is a directory"
        user_perm=${ACTUAL_PERMISSION:0:1}
        if [ $((user_perm & 1)) -eq 0 ]; then
            echo "⚠️  WARNING: Directory is not executable by owner (cannot be traversed)"
            EXIT_CODE=1
        else
            echo "✅ Directory is executable by owner"
        fi
    else
        echo "ℹ️  This is a regular file"
    fi
}

# Main execution
validate_arguments "$@"
validate_file_exists
validate_format
gather_file_info
validate_permissions_match
validate_file_ownership
perform_security_analysis
validate_directory_permissions

exit $EXIT_CODE

