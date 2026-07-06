#!/bin/bash
set -e

# --- CONFIGURATION ---
VERSION="1.3.0" 
PYTHON_SOURCE_FILE="main.py" 
BUNDLE_ID="com.kcoding.espflasher"
OUTPUT_PKG="espflasher.pkg"
BUILD_DIR="espflasher-build"

echo "=== ESP Flasher Advanced Multi-Choice Builder ==="

if [ "$(uname)" != "Darwin" ]; then
    echo "Error: You must run this build script on macOS."
    exit 1
fi

if [ ! -f "$PYTHON_SOURCE_FILE" ]; then
    echo "Error: Source script '$PYTHON_SOURCE_FILE' not found."
    exit 1
fi

# Clean environment
rm -rf "$BUILD_DIR"
rm -f "$OUTPUT_PKG"

# 1. Build the separate Fresh Install core package
mkdir -p "$BUILD_DIR/fresh_root/usr/local/bin"
cp "$PYTHON_SOURCE_FILE" "$BUILD_DIR/fresh_root/usr/local/bin/espflasher"
chmod +x "$BUILD_DIR/fresh_root/usr/local/bin/espflasher"

pkgbuild --root "$BUILD_DIR/fresh_root" \
         --identifier "${BUNDLE_ID}.fresh" \
         --version "$VERSION" \
         --install-location / \
         "$BUILD_DIR/fresh_core.pkg"

# 2. Build the separate Upgrade core package
mkdir -p "$BUILD_DIR/upgrade_root/usr/local/bin"
cp "$PYTHON_SOURCE_FILE" "$BUILD_DIR/upgrade_root/usr/local/bin/espflasher"
chmod +x "$BUILD_DIR/upgrade_root/usr/local/bin/espflasher"

pkgbuild --root "$BUILD_DIR/upgrade_root" \
         --identifier "${BUNDLE_ID}.upgrade" \
         --version "$VERSION" \
         --install-location / \
         "$BUILD_DIR/upgrade_core.pkg"

# 3. Create the Custom UI Layout Blueprint (Distribution XML)
# This includes embedded JavaScript to look for existing files on the user's Mac
cat << 'EOF' > "$BUILD_DIR/distribution.xml"
<?xml version="1.0" encoding="utf-8"?>
<installer-gui-script minSpecVersion="1">
    <title>Espflasher Pro Setup Wizard</title>
    <options customize="always" require-scripts="false"/>
    
    <!-- Embedded JS logic to detect an existing binary on the system -->
    <script>
        function checkExistingInstall() {
            return system.files.fileExistsAtPath('/usr/local/bin/espflasher');
        }
    </script>

    <!-- Choice 1: Fresh Installation Option -->
    <choice id="fresh_install"
            title="Fresh Installation (Recommended if new)"
            description="Performs a clean installation of Espflasher onto this Mac."
            start_selected="!checkExistingInstall()"
            start_enabled="!checkExistingInstall()">
        <pkg-ref id="com.kcode-15.espflasher.fresh"/>
    </choice>

    <!-- Choice 2: Upgrade Option -->
    <choice id="upgrade_install"
            title="Upgrade Tool (Overwrites old version)"
            description="Safely overwrites your existing Espflasher deployment with version 1.3.0."
            start_selected="checkExistingInstall()"
            start_enabled="checkExistingInstall()">
        <pkg-ref id="com.kcode-15.espflasher.upgrade"/>
    </choice>

    <!-- UI Map Layer -->
    <choices-outline>
        <line choice="fresh_install"/>
        <line choice="upgrade_install"/>
    </choices-outline>

    <!-- Map Choices to Component Packages -->
    <pkg-ref id="com.kcode-15.espflasher.fresh" version="1.3.0" onConclusion="none">fresh_core.pkg</pkg-ref>
    <pkg-ref id="com.kcode-15.espflasher.upgrade" version="1.3.0" onConclusion="none">upgrade_core.pkg</pkg-ref>
</installer-gui-script>
EOF

# 4. Compile the final combined installer package 
echo "Stitching component choices into distribution archive..."
productbuild --distribution "$BUILD_DIR/distribution.xml" \
             --package-path "$BUILD_DIR" \
             "$OUTPUT_PKG"

rm -rf "$BUILD_DIR"

echo "========================================="
echo "Success! Choice-ready package created: $OUTPUT_PKG"
echo "========================================="

