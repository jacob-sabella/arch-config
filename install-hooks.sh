#!/bin/bash
# Install git hooks for this repo

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_ROOT" ]; then
    echo "Not in a git repo."
    exit 1
fi

HOOKS_DIR="$REPO_ROOT/.git/hooks"

install_hook() {
    local name="$1"
    local src="$REPO_ROOT/.github/hooks/$name"
    local dst="$HOOKS_DIR/$name"

    if [ ! -f "$src" ]; then
        echo "No hook source at $src, skipping."
        return
    fi

    cp "$src" "$dst"
    chmod +x "$dst"
    echo "Installed: $name"
}

# Check trufflehog available
if [ ! -x "$HOME/.local/bin/trufflehog" ]; then
    echo "WARNING: trufflehog not found at ~/.local/bin/trufflehog"
    echo "Install: curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b ~/.local/bin"
fi

install_hook pre-commit
echo "Done."
