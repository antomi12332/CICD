@echo off
setlocal

echo ============================================
echo Installing JIRA Git Hook
echo ============================================
echo.
echo This hook will automatically add JIRA issue keys to commit messages
echo based on branch names (e.g., PROJ-123-feature-branch)
echo.

:: Check if we're in a Git repository
git rev-parse --git-dir >nul 2>&1
if errorlevel 1 (
    echo ERROR: Not in a Git repository!
    echo Please run this script from within a Git repository.
    pause
    exit /b 1
)

:: Set repo path if needed
set "REPO_DIR=%cd%"
set "HOOK_PATH=%REPO_DIR%\.git\hooks\prepare-commit-msg"

echo Creating Git hook at: %HOOK_PATH%
echo.

:: Create a more robust hook that works with different Git installations
> "%HOOK_PATH%" echo #!/bin/sh
>> "%HOOK_PATH%" echo.
>> "%HOOK_PATH%" echo # JIRA Git Hook - Auto-add issue keys to commit messages
>> "%HOOK_PATH%" echo # Compatible with Git Bash, GitHub Desktop, and command line Git
>> "%HOOK_PATH%" echo.
>> "%HOOK_PATH%" echo COMMIT_MSG_FILE="$1"
>> "%HOOK_PATH%" echo COMMIT_SOURCE="$2"
>> "%HOOK_PATH%" echo.
>> "%HOOK_PATH%" echo # Skip for merge commits and other special cases
>> "%HOOK_PATH%" echo if [ "$COMMIT_SOURCE" = "merge" ] ^|^| [ "$COMMIT_SOURCE" = "squash" ] ^|^| [ "$COMMIT_SOURCE" = "commit" ]; then
>> "%HOOK_PATH%" echo     exit 0
>> "%HOOK_PATH%" echo fi
>> "%HOOK_PATH%" echo.
>> "%HOOK_PATH%" echo # Get current branch name
>> "%HOOK_PATH%" echo BRANCH=$(git symbolic-ref --short HEAD 2^>/dev/null ^|^| git rev-parse --short HEAD 2^>/dev/null)
>> "%HOOK_PATH%" echo.
>> "%HOOK_PATH%" echo # Try to extract JIRA issue key from branch name
>> "%HOOK_PATH%" echo # First try with standard shell tools (works in Git Bash)
>> "%HOOK_PATH%" echo if command -v grep ^>/dev/null 2^>^&1; then
>> "%HOOK_PATH%" echo     ISSUE_KEY=$(echo "$BRANCH" ^| grep -oE '[A-Z][A-Z0-9]+-[0-9]+' ^| head -1)
>> "%HOOK_PATH%" echo else
>> "%HOOK_PATH%" echo     # Fallback to PowerShell for Windows without Git Bash
>> "%HOOK_PATH%" echo     ISSUE_KEY=$(powershell.exe -NoProfile -Command "if ('$BRANCH' -match '[A-Z][A-Z0-9]+-[0-9]+') { \$matches[0] } else { '' }" 2^>/dev/null ^|^| echo "")
>> "%HOOK_PATH%" echo fi
>> "%HOOK_PATH%" echo.
>> "%HOOK_PATH%" echo # Only proceed if we found an issue key
>> "%HOOK_PATH%" echo if [ -n "$ISSUE_KEY" ] ^&^& [ "$ISSUE_KEY" != "" ]; then
>> "%HOOK_PATH%" echo     # Check if the commit message already has a JIRA key
>> "%HOOK_PATH%" echo     if ! grep -q "^\[.*\]" "$COMMIT_MSG_FILE" 2^>/dev/null; then
>> "%HOOK_PATH%" echo         # Prepend the JIRA key to the commit message
>> "%HOOK_PATH%" echo         if command -v sed ^>/dev/null 2^>^&1; then
>> "%HOOK_PATH%" echo             sed -i.bak "1s/^/[$ISSUE_KEY] /" "$COMMIT_MSG_FILE"
>> "%HOOK_PATH%" echo         else
>> "%HOOK_PATH%" echo             # PowerShell fallback
>> "%HOOK_PATH%" echo             powershell.exe -NoProfile -Command "if (Test-Path '$COMMIT_MSG_FILE') { \$content = Get-Content '$COMMIT_MSG_FILE' -Raw; Set-Content '$COMMIT_MSG_FILE' -Value \"[$ISSUE_KEY] \$content\" }" 2^>/dev/null
>> "%HOOK_PATH%" echo         fi
>> "%HOOK_PATH%" echo     fi
>> "%HOOK_PATH%" echo fi

:: Make the hook executable (important for Unix-like environments)
if exist "%HOOK_PATH%" (
    :: Try to make it executable using Git's built-in method
    git update-index --chmod=+x "%HOOK_PATH%" 2>nul
    
    :: Ensure Git uses the hooks directory
    git config core.hooksPath .git/hooks
    
    echo.
    echo ============================================
    echo SUCCESS: Git hook installed successfully!
    echo ============================================
    echo.
) else (
    echo ERROR: Failed to create hook file!
    exit /b 1
)

endlocal

