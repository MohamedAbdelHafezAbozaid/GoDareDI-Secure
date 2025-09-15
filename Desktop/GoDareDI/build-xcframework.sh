#!/bin/bash

# GoDareDI XCFramework Builder
# Creates a proper XCFramework using Xcode build system

set -e

echo "🔒 Building GoDareDI XCFramework"
echo "================================="

# Configuration
FRAMEWORK_NAME="GoDareDI"
SCHEME_NAME="GoDareDI"
BUILD_DIR="Build"
ARCHIVE_DIR="Archives"
XCFRAMEWORK_DIR="GoDareDI.xcframework"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf "$BUILD_DIR"
rm -rf "$ARCHIVE_DIR"
rm -rf "$XCFRAMEWORK_DIR"

# Create directories
mkdir -p "$BUILD_DIR"
mkdir -p "$ARCHIVE_DIR"

# Create Xcode project
echo "📱 Creating Xcode project..."
swift package generate-xcodeproj --output "$BUILD_DIR"

# Build for iOS Device
echo "📱 Building for iOS Device..."
xcodebuild archive \
    -project "$BUILD_DIR/GoDareDI.xcodeproj" \
    -scheme "$SCHEME_NAME" \
    -destination "generic/platform=iOS" \
    -archivePath "$ARCHIVE_DIR/GoDareDI-iOS.xcarchive" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Build for iOS Simulator
echo "📱 Building for iOS Simulator..."
xcodebuild archive \
    -project "$BUILD_DIR/GoDareDI.xcodeproj" \
    -scheme "$SCHEME_NAME" \
    -destination "generic/platform=iOS Simulator" \
    -archivePath "$ARCHIVE_DIR/GoDareDI-iOS-Simulator.xcarchive" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Build for macOS
echo "💻 Building for macOS..."
xcodebuild archive \
    -project "$BUILD_DIR/GoDareDI.xcodeproj" \
    -scheme "$SCHEME_NAME" \
    -destination "generic/platform=macOS" \
    -archivePath "$ARCHIVE_DIR/GoDareDI-macOS.xcarchive" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Create XCFramework
echo "📦 Creating XCFramework..."
xcodebuild -create-xcframework \
    -framework "$ARCHIVE_DIR/GoDareDI-iOS.xcarchive/Products/Library/Frameworks/GoDareDI.framework" \
    -framework "$ARCHIVE_DIR/GoDareDI-iOS-Simulator.xcarchive/Products/Library/Frameworks/GoDareDI.framework" \
    -framework "$ARCHIVE_DIR/GoDareDI-macOS.xcarchive/Products/Library/Frameworks/GoDareDI.framework" \
    -output "$XCFRAMEWORK_DIR"

echo "✅ XCFramework created successfully!"
echo "📁 Location: $XCFRAMEWORK_DIR"
echo ""
echo "🔒 Your source code is now compiled and protected!"
echo "📦 The XCFramework contains only binary code and public headers"
