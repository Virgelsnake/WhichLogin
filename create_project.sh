#!/bin/bash
set -e

PROJECT_NAME="WhichLogin"
BUNDLE_ID="com.virgelsnake.WhichLogin"

# Create project using xcodegen if available, otherwise manual
if command -v xcodegen &> /dev/null; then
    echo "Using xcodegen..."
else
    echo "Creating project manually with Xcode..."
    # We'll open Xcode to create the project
    open -a Xcode
    echo "Please create a new macOS App project named 'WhichLogin' with SwiftUI"
    echo "Bundle ID: $BUNDLE_ID"
    echo "Then press Enter to continue..."
    read
fi
