#!/bin/bash

# Exit immediately if any command fails
set -e

echo "=== ESP Flasher Installer ==="

# 1. Enforce macOS platform check
if [ "$(uname)" != "Darwin" ]; then
    echo "Error: This installer only supports macOS."
    exit 1
fi

# 2. Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required but not found."
    echo "Please install Python 3 or Homebrew first."
    exit 1
fi

# 3. Create a symbolic link in the user's local binary path
# This allows typing "espflasher" from any terminal window
INSTALL_DIR="$HOME/.local/bin"
TARGET_SCRIPT="$(pwd)/your_script_name.py" # Replace with your actual filename

echo "Creating installation directory..."
mkdir -p "$INSTALL_DIR"

echo "Configuring executable permissions..."
chmod +x "$TARGET_SCRIPT"

echo "Creating terminal shortcut..."
ln -sf "$TARGET_SCRIPT" "$INSTALL_DIR/espflasher"

# 4. Ensure the local bin path is in the user's environment profile
SHELL_PROFILE="$HOME/.zshrc"
if [ ! -f "$SHELL_PROFILE" ]; then
    SHELL_PROFILE="$HOME/.bash_profile"
fi

if ! grep -q "$INSTALL_DIR" "$SHELL_PROFILE"; then
    echo "Updating system PATH profile..."
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_PROFILE"
fi

echo "========================================="
echo "Success! Installation completed."
echo "Please restart your terminal or run: source $SHELL_PROFILE"
echo "Then type 'espflasher' to run your tool."
echo "========================================="
