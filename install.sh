#!/bin/bash

set -e

# Configuration
DEST_DIR="$HOME/.config"
FONT_DIR="PhotoGimp-fresh/fonts"
ICON_SRC="./gimp.png"
ICON_DEST_DIR="$HOME/.local/share/icons"
DESKTOP_FILE_NAME="org.gimp.GIMP.desktop"

# Detect GIMP config directory
GIMP_CONFIG_DIR=""
[ -d "$DEST_DIR/GIMP" ] && GIMP_CONFIG_DIR="$DEST_DIR/GIMP"
[ -d "$DEST_DIR/gimp" ] && GIMP_CONFIG_DIR="$DEST_DIR/gimp"

if [ -z "$GIMP_CONFIG_DIR" ]; then
  echo "Error: GIMP configuration directory not found!"
  echo "Please make sure GIMP is installed and has been run at least once."
  exit 1
fi

GIMP_USER_DIR="$GIMP_CONFIG_DIR/3.0"
DESKTOP_FILE_PATH="$HOME/.local/share/applications/$DESKTOP_FILE_NAME"

echo "Installing GIMP Customization..."

# Silent font extraction
echo "Unpacking fonts..."
tar -xf "$FONT_DIR/fonts-1.tar.xz" -C "$FONT_DIR" 2>/dev/null
tar -xf "$FONT_DIR/fonts-2.tar.xz" -C "$FONT_DIR" 2>/dev/null

# Clean existing config
echo "Removing old configuration..."
rm -rf "$GIMP_CONFIG_DIR"

# Install files
echo "Copying customization files..."
mkdir -p "$GIMP_USER_DIR"
cp -rf PhotoGimp-fresh/* "$GIMP_USER_DIR"
rm -f "$GIMP_USER_DIR/fonts/fonts-"*.tar.xz

# Install icon
echo "Setting up icon..."
mkdir -p "$ICON_DEST_DIR"
cp -f "$ICON_SRC" "$ICON_DEST_DIR/gimp.png"

# Flatpak desktop file handling
echo "Configuring application shortcut..."
DESKTOP_SOURCES=(
  "/var/lib/flatpak/exports/share/applications/$DESKTOP_FILE_NAME"
  "$HOME/.local/share/flatpak/exports/share/applications/$DESKTOP_FILE_NAME"
)

for source in "${DESKTOP_SOURCES[@]}"; do
  if [ -f "$source" ]; then
    mkdir -p "$(dirname "$DESKTOP_FILE_PATH")"
    cp -f "$source" "$DESKTOP_FILE_PATH"
    sed -i "s|^Icon=.*|Icon=$ICON_DEST_DIR/gimp.png|" "$DESKTOP_FILE_PATH"
    chmod +x "$DESKTOP_FILE_PATH"
    break
  fi
done

echo "Installation complete. Restart GIMP to see the changes."
