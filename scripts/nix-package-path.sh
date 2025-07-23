#!/usr/bin/env bash
# Script to get the full nix store path for any package
set -e  # Exit on any error

# Function to display usage
usage() {
    echo "Usage: $0 <package-name>"
    echo "Example: $0 zig"
    echo "Example: $0 nodejs"
    echo "Example: $0 python3"
    exit 1
}

# Check if package name is provided
if [ $# -eq 0 ]; then
    echo "Error: Package name is required"
    usage
fi

PACKAGE_NAME="$1"

echo "Looking up nix store path for package: $PACKAGE_NAME"

# Try to get the package path
if PACKAGE_PATH=$(nix-build '<nixpkgs>' -A "$PACKAGE_NAME" --no-out-link 2>/dev/null); then
    echo "Package path: $PACKAGE_PATH"
    echo "Binary path: $PACKAGE_PATH/bin/$PACKAGE_NAME"
    
    # Check if the binary exists
    if [ -f "$PACKAGE_PATH/bin/$PACKAGE_NAME" ]; then
        echo "✓ Binary exists at: $PACKAGE_PATH/bin/$PACKAGE_NAME"
    else
        echo "⚠ Binary not found at expected location"
        echo "Available binaries in $PACKAGE_PATH/bin/:"
        if [ -d "$PACKAGE_PATH/bin" ]; then
            ls -la "$PACKAGE_PATH/bin/" 2>/dev/null || echo "No bin directory found"
        fi
    fi
else
    echo "Error: Package '$PACKAGE_NAME' not found in nixpkgs"
    echo "Try checking the exact package name with: nix search nixpkgs $PACKAGE_NAME"
    exit 1
fi