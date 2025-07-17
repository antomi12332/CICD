#!/bin/bash

echo "============================================"
echo "Installing JIRA Git Hook"
echo "============================================"
echo
echo "This hook will automatically add JIRA issue keys to commit messages"
echo "based on branch names (e.g., PROJ-123-feature-branch)"
echo

# Check if we're in a Git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "ERROR: Not in a Git repository!"
    echo "Please run this script from within a Git repository."
    exit 1
fi

# Set repo path
REPO_DIR="$(pwd)"
HOOK_PATH="$REPO_DIR/.git/hooks/prepare-commit-msg"

echo "Creating Git hook at: $HOOK_PATH"
echo

# Create the Git hook
cat > "$HOOK_PATH" << 'EOF'
#!/bin/bash

# JIRA Git Hook - Auto-add issue keys to commit messages
# Compatible with macOS and Unix-like systems

COMMIT_MSG_FILE="$1"
COMMIT_SOURCE="$2"

# Skip for merge commits and other special cases
if [ "$COMMIT_SOURCE" = "merge" ] || [ "$COMMIT_SOURCE" = "squash" ] || [ "$COMMIT_SOURCE" = "commit" ]; then
    exit 0
fi

# Get current branch name
BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

# Extract JIRA issue key from branch name using grep
ISSUE_KEY=$(echo "$BRANCH" | grep -oE '[A-Z][A-Z0-9]+-[0-9]+' | head -1)

# Only proceed if we found an issue key
if [ -n "$ISSUE_KEY" ] && [ "$ISSUE_KEY" != "" ]; then
    # Check if the commit message already has a JIRA key
    if ! grep -q "^\[.*\]" "$COMMIT_MSG_FILE" 2>/dev/null; then
        # Prepend the JIRA key to the commit message
        sed -i.bak "1s/^/[$ISSUE_KEY] /" "$COMMIT_MSG_FILE"
        # Clean up backup file
        rm -f "$COMMIT_MSG_FILE.bak"
    fi
fi
EOF

# Make the hook executable
chmod +x "$HOOK_PATH"

# Ensure Git uses the hooks directory
git config core.hooksPath .git/hooks

if [ -f "$HOOK_PATH" ]; then
    echo
    echo "============================================"
    echo "SUCCESS: Git hook installed successfully!"
    echo "============================================"
    echo
    echo "The hook is now active and will automatically add JIRA issue keys"
    echo "to your commit messages based on your branch names."
    echo
    echo "Example: If your branch is 'PROJ-123-feature-login',"
    echo "commits will be prefixed with '[PROJ-123]'"
    echo
else
    echo "ERROR: Failed to create hook file!"
    exit 1
fi
