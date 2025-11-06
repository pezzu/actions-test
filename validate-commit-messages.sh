#!/bin/bash

# Script to validate commit messages start with THE_KEYWORD
# Usage: ./validate-commit-messages.sh [base-branch] [head-branch]

set -e

BASE_BRANCH=${1:-main}
HEAD_BRANCH=${2:-HEAD}
REQUIRED_KEYWORD="THE_KEYWORD"

echo "Validating commit messages between $BASE_BRANCH and $HEAD_BRANCH..."
echo "Required keyword: $REQUIRED_KEYWORD"

# Get the commit range
if [ "$HEAD_BRANCH" = "HEAD" ]; then
    COMMIT_RANGE="$BASE_BRANCH...HEAD"
else
    COMMIT_RANGE="$BASE_BRANCH...$HEAD_BRANCH"
fi

# Get commit messages in the range
COMMITS=$(git log --pretty=format:"%s" "$COMMIT_RANGE")

if [ -z "$COMMITS" ]; then
    echo "No commits found in range $COMMIT_RANGE"
    exit 0
fi

echo "Checking commits:"
echo "$COMMITS"
echo ""

# Check each commit message
INVALID_COMMITS=0
while IFS= read -r commit_msg; do
    if [[ ! "$commit_msg" =~ ^$REQUIRED_KEYWORD ]]; then
        echo "❌ Invalid commit message: '$commit_msg'"
        echo "   Must start with '$REQUIRED_KEYWORD'"
        INVALID_COMMITS=$((INVALID_COMMITS + 1))
    else
        echo "✅ Valid commit message: '$commit_msg'"
    fi
done <<< "$COMMITS"

if [ $INVALID_COMMITS -gt 0 ]; then
    echo ""
    echo "❌ Validation failed: $INVALID_COMMITS commit(s) do not start with '$REQUIRED_KEYWORD'"
    echo "Please update commit messages to start with '$REQUIRED_KEYWORD'"
    exit 1
else
    echo ""
    echo "✅ All commit messages are valid!"
    exit 0
fi