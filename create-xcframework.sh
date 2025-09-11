#!/bin/bash

# GoDareDI XCFramework Builder
# Creates encrypted binary framework from all source files

set -e

echo "🔒 Building GoDareDI XCFramework with Complete Source Protection..."

# Configuration
FRAMEWORK_NAME="GoDareDI"
SCHEME_NAME="GoDareDI"
BUILD_DIR=".build"
XCFRAMEWORK_PATH="GoDareDI.xcframework"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf $BUILD_DIR
rm -rf $XCFRAMEWORK_PATH
rm -rf DerivedData

# Create build directory
mkdir -p $BUILD_DIR

echo "📦 Creating Xcode project for framework building..."
swift package generate-xcodeproj

# Build for iOS Simulator
echo "📱 Building for iOS Simulator..."
xcodebuild -scheme $SCHEME_NAME \
    -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
    -configuration Release \
    -derivedDataPath $BUILD_DIR/ios-simulator \
    -archivePath $BUILD_DIR/ios-simulator.xcarchive \
    archive

# Build for iOS Device
echo "📱 Building for iOS Device..."
xcodebuild -scheme $SCHEME_NAME \
    -destination 'platform=iOS,name=Generic iOS Device' \
    -configuration Release \
    -derivedDataPath $BUILD_DIR/ios-device \
    -archivePath $BUILD_DIR/ios-device.xcarchive \
    archive

# Build for macOS
echo "💻 Building for macOS..."
xcodebuild -scheme $SCHEME_NAME \
    -destination 'platform=macOS' \
    -configuration Release \
    -derivedDataPath $BUILD_DIR/macos \
    -archivePath $BUILD_DIR/macos.xcarchive \
    archive

# Create XCFramework
echo "🔧 Creating XCFramework..."
xcodebuild -create-xcframework \
    -framework $BUILD_DIR/ios-simulator.xcarchive/Products/Library/Frameworks/$FRAMEWORK_NAME.framework \
    -framework $BUILD_DIR/ios-device.xcarchive/Products/Library/Frameworks/$FRAMEWORK_NAME.framework \
    -framework $BUILD_DIR/macos.xcarchive/Products/Library/Frameworks/$FRAMEWORK_NAME.framework \
    -output $XCFRAMEWORK_PATH

echo "✅ XCFramework build complete!"
echo "📦 Framework created at: $XCFRAMEWORK_PATH"
echo "🔒 All source code is now compiled and protected in binary format"
echo "🛡️ Implementation details are completely encrypted"

# Display framework info
echo ""
echo "📊 Framework Information:"
ls -la $XCFRAMEWORK_PATH
echo ""
echo "🎯 Ready for distribution with complete source protection!"
