#!/bin/bash
set -e

# --- CONFIGURATION ---
BUNDLE_ID="com.yourusername.espflasher"
VERSION="1.0.0"
OUTPUT_UNINSTALL_PKG="uninstall_espflasher.pkg"
BUILD_DIR="espflasher-uninstall-build"

echo "=== ESP Flasher Uninstaller .pkg Builder ==="

if [ "$(uname)" != "Darwin" ]; then
    echo "Error: You must run this build script on macOS."
    exit 1
fi

rm -rf "$BUILD_DIR"
rm -f "$OUTPUT_UNINSTALL_PKG"

mkdir -p "$BUILD_DIR/scripts"

# Generate the advanced postinstall script
cat << 'EOF' > "$BUILD_DIR/scripts/postinstall"
#!/bin/bash
set -e

# 1. Clear system-wide location
SYSTEM_PATH="/usr/local/bin/espflasher"
if [ -f "$SYSTEM_PATH" ]; then
    echo "Removing system-wide binary..."
    rm -f "$SYSTEM_PATH"
fi

# 2. Safely find the logged-in user's home directory (since pkg runs as root)
CONSOLE_USER=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ { print $3 }')
if [ -n "$CONSOLE_USER" ] && [ "$CONSOLE_USER" != "loginwindow" ]; then
    USER_PATH="/Users/$CONSOLE_USER/.local/bin/espflasher"
    if [ -f "$USER_PATH" ]; then
        echo "Removing user-level binary for $CONSOLE_USER..."
        rm -f "$USER_PATH"
    fi
fi

# 3. Clear system installation history receipts
BUNDLE_ID="com.yourusername.espflasher"
if pkgutil --pkgs | grep -q "^${BUNDLE_ID}$"; then
    pkgutil --forget "$BUNDLE_ID"
fi
if pkgutil --pkgs | grep -q "^${BUNDLE_ID}.uninstall$"; then
    pkgutil --forget "${BUNDLE_ID}.uninstall"
fi

exit 0
EOF

chmod +x "$BUILD_DIR/scripts/postinstall"

echo "Compiling universal uninstaller package..."
pkgbuild --nopayload \
         --scripts "$BUILD_DIR/scripts" \
         --identifier "${BUNDLE_ID}.uninstall" \
         --version "$VERSION" \
         "$OUTPUT_UNINSTALL_PKG"

rm -rf "$BUILD_DIR"

echo "========================================="
echo "Success! Universal uninstaller created."
echo "========================================="

