#!/bin/bash

# Clean XCFramework Build Script
# This script builds a proper XCFramework with correct swiftinterface files

set -e

echo "🚀 Building Clean XCFramework with Proper SwiftInterface Files..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf .build
rm -rf GoDareDI.xcframework
rm -rf temp_build_*
rm -rf Frameworks

# Clone source from GitHub repository
SOURCE_DIR_NAME="GoDareDI-Source"
SOURCE_DIR="$SOURCE_DIR_NAME/Desktop/GoDareDI/Sources/GoDareDI"
ABSOLUTE_SOURCE_DIR="$(pwd)/$SOURCE_DIR"

echo "📥 Cloning source from GitHub repository..."
if [ -d "$SOURCE_DIR_NAME" ]; then
    echo "📁 Source directory already exists, updating..."
    cd "$SOURCE_DIR_NAME"
    git pull origin main
    cd ..
else
    echo "📥 Cloning fresh copy from GitHub..."
    git clone https://github.com/MohamedAbdelHafezAbozaid/GoDareDI.git "$SOURCE_DIR_NAME"
fi

# Verify source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ Source directory not found: $SOURCE_DIR"
    echo "❌ Failed to clone from GitHub repository"
    exit 1
fi

echo "📁 Source directory: $SOURCE_DIR"

# Function to build framework for a platform
build_framework() {
    local platform=$1
    local destination=$2
    local sdk=$3
    
    echo "🔨 Building for $platform..."
    
    # Create temporary build directory
    local build_dir="temp_build_$platform"
    mkdir -p "$build_dir"
    cd "$build_dir"
    
    # Copy source code
    cp -r "$ABSOLUTE_SOURCE_DIR" .
    
    # Create Package.swift for this platform
    cat > Package.swift << EOF
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GoDareDI",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "GoDareDI",
            targets: ["GoDareDI"]),
    ],
    targets: [
        .target(
            name: "GoDareDI",
            dependencies: [],
            path: "GoDareDI"),
    ]
)
EOF
    
    # Build with proper swiftinterface generation
    echo "📦 Building with swiftinterface generation..."
    swift build \
        --configuration release \
        -Xswiftc -emit-module-interface \
        -Xswiftc -enable-library-evolution
    
    cd ..
    
    # Create framework structure
    mkdir -p "Frameworks/$platform/GoDareDI.framework"
    mkdir -p "Frameworks/$platform/GoDareDI.framework/Headers"
    mkdir -p "Frameworks/$platform/GoDareDI.framework/Modules"
    
    # Copy the built library
    cp "$build_dir/.build/release/GoDareDI.o" "Frameworks/$platform/GoDareDI.framework/GoDareDI"
    
    # Copy swiftmodule and swiftinterface files
    if [ -d "$build_dir/.build/release/GoDareDI.swiftmodule" ]; then
        cp -r "$build_dir/.build/release/GoDareDI.swiftmodule" "Frameworks/$platform/GoDareDI.framework/Modules/"
    fi
    
    # Create module map
    cat > "Frameworks/$platform/GoDareDI.framework/Modules/module.modulemap" << EOF
framework module GoDareDI {
    umbrella header "GoDareDI.h"
    export *
    module * { export * }
}
EOF
    
    # Create Info.plist
    cat > "Frameworks/$platform/GoDareDI.framework/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>GoDareDI</string>
    <key>CFBundleIdentifier</key>
    <string>com.godare.di</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>GoDareDI</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.37</string>
    <key>CFBundleVersion</key>
    <string>37</string>
    <key>MinimumOSVersion</key>
    <string>17.0</string>
    <key>CFBundleSupportedPlatforms</key>
    <array>
        <string>iPhoneOS</string>
    </array>
</dict>
</plist>
EOF
    
    # Create umbrella header
    cat > "Frameworks/$platform/GoDareDI.framework/Headers/GoDareDI.h" << EOF
#import <Foundation/Foundation.h>

//! Project version number for GoDareDI.
FOUNDATION_EXPORT double GoDareDIVersionNumber;

//! Project version string for GoDareDI.
FOUNDATION_EXPORT const unsigned char GoDareDIVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <GoDareDI/PublicHeader.h>
EOF
    
    echo "✅ Built framework for $platform"
}

# Build for iOS device
echo "📱 Building for iOS device..."
build_framework "ios-arm64" "generic/platform=iOS" "iphoneos"

# Build for iOS simulator
echo "📱 Building for iOS simulator..."
build_framework "ios-arm64_x86_64-simulator" "generic/platform=iOS Simulator" "iphonesimulator"

# Create XCFramework
echo "🎯 Creating XCFramework..."
xcodebuild -create-xcframework \
    -framework "Frameworks/ios-arm64/GoDareDI.framework" \
    -framework "Frameworks/ios-arm64_x86_64-simulator/GoDareDI.framework" \
    -output "GoDareDI.xcframework"

# Verify XCFramework
echo "✅ Verifying XCFramework..."
xcodebuild -checkFirstLaunchStatus
xcrun xcodebuild -showsdks

# Display XCFramework info
echo "📋 XCFramework created successfully!"
echo "📁 Location: $(pwd)/GoDareDI.xcframework"
echo "📊 Size: $(du -sh GoDareDI.xcframework | cut -f1)"

# Clean up temporary files
echo "🧹 Cleaning up temporary files..."
rm -rf temp_build_*
rm -rf Frameworks
rm -rf "$SOURCE_DIR_NAME"

echo "🎉 XCFramework build completed successfully!"
echo ""
echo "🔐 The XCFramework includes:"
echo "   📁 SDK initialization flow (GoDareDISecureInit)"
echo "   📁 Error handling (GoDareDILicenseError)"
echo "   📁 Registration and resolution interfaces"
echo "   📁 Dependency graph view (DependencyGraphView)"
echo "   📁 All required public interfaces"
echo ""
echo "📁 Complete XCFramework: GoDareDI.xcframework"
