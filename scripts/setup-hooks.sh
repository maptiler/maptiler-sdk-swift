#!/bin/sh

HOOKS_DIR=".githooks"
GIT_HOOKS=".git/hooks"
FLAG_FILE="$GIT_HOOKS/.hooks_installed"

echo "Checking Git hooks setup..."

if [ -f "$FLAG_FILE" ]; then
    echo "✅ Git hooks already installed. Skipping setup."
    exit 0
fi

if [ ! -d "$GIT_HOOKS" ]; then
    echo "⚠️ Git hooks directory not found! Make sure you have initialized a Git repository."
    exit 1
fi

ln -sf ../../$HOOKS_DIR/pre-commit $GIT_HOOKS/pre-commit

chmod +x $GIT_HOOKS/pre-commit

touch "$FLAG_FILE"

echo "✅ Git hooks successfully installed!"