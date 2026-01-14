#!/bin/bash

# Build the app
echo "Building Calculator..."
swift build -c release

# Get the executable path
EXEC_PATH=".build/release/CalculatorMac"

# Create app bundle structure
APP_NAME="Calculator.app"
APP_DIR="$APP_NAME/Contents"
MACOS_DIR="$APP_DIR/MacOS"
RESOURCES_DIR="$APP_DIR/Resources"

echo "Creating app bundle..."
rm -rf "$APP_NAME"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy executable
cp "$EXEC_PATH" "$MACOS_DIR/Calculator"

# Copy Info.plist
cp Sources/CalculatorMac/Info.plist "$APP_DIR/"

# Update Info.plist with correct executable name
sed -i '' 's/CalculatorMac/Calculator/g' "$APP_DIR/Info.plist"

echo "App bundle created at: $APP_NAME"
echo ""
echo "To run the app:"
echo "  open $APP_NAME"
echo ""
echo "Or double-click Calculator.app in Finder"
