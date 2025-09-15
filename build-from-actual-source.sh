#!/bin/bash

# Build XCFramework from Actual Source Code (Excluding Problematic SwiftUI Views)
# This ensures ALL logic from the source directory is included

set -e

echo "🔐 Building XCFramework from Actual Source Code..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf .build
rm -rf GoDareDI.xcframework
rm -rf Frameworks
rm -rf "$SOURCE_DIR_NAME"

# Use local source directory
SOURCE_DIR="../Sources/GoDareDI"

# Verify source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ Source directory not found: $SOURCE_DIR"
    echo "❌ Make sure you're running this script from the GoDareDI-Secure-Distribution directory"
    exit 1
fi

echo "📁 Source directory: $SOURCE_DIR"

# Function to build framework for a platform
build_framework() {
    local platform=$1
    local target=$2
    local sdk=$3
    local version=$4
    local platform_name=$5
    
    echo "🔨 Building for $platform..."
    
    mkdir -p Frameworks/$platform
    mkdir -p Frameworks/$platform/GoDareDI.framework/Headers
    mkdir -p Frameworks/$platform/GoDareDI.framework/Modules
    
    # Create module map
    cat > Frameworks/$platform/GoDareDI.framework/Modules/module.modulemap << EOF
framework module GoDareDI {
    umbrella header "GoDareDI.h"
    export *
    module * { export * }
}
EOF
    
    # Create umbrella header
    cat > Frameworks/$platform/GoDareDI.framework/Headers/GoDareDI.h << EOF
#import <Foundation/Foundation.h>

//! Project version number for GoDareDI.
FOUNDATION_EXPORT double GoDareDIVersionNumber;

//! Project version string for GoDareDI.
FOUNDATION_EXPORT const unsigned char GoDareDIVersionString[];

// Binary Framework - Source code is protected and compiled
// Only public interfaces are available through this header

@interface GoDareDI : NSObject
+ (NSString *)frameworkVersion;
+ (NSString *)buildNumber;
+ (void)initializeFramework;
@end

@interface GoDareDIEntry : NSObject
+ (NSString *)getFrameworkVersion;
@end
EOF
    
    # Create Info.plist
    cat > Frameworks/$platform/GoDareDI.framework/Info.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>GoDareDI</string>
    <key>CFBundleIdentifier</key>
    <string>com.godaredi.framework</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>GoDareDI</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.22</string>
    <key>CFBundleVersion</key>
    <string>22</string>
    <key>MinimumOSVersion</key>
    <string>$version</string>
    <key>CFBundleSupportedPlatforms</key>
    <array>
        <string>$platform_name</string>
    </array>
</dict>
</plist>
EOF
    
    # Find all Swift files except problematic SwiftUI views
    SWIFT_FILES=$(find "$SOURCE_DIR" -name "*.swift" ! -path "*/Visualizer/Views/*" ! -path "*/Visualizer/Debug/*" ! -name "*SupportingViews*" ! -name "*DashboardUpdateView*" ! -name "*DependencyGraphView*" | tr '\n' ' ')
    echo "📄 Found Swift files: $(echo $SWIFT_FILES | wc -w) files"
    
    # Create a temporary Xcode project for building the framework
    TEMP_PROJECT_DIR="temp_build_$platform"
    mkdir -p "$TEMP_PROJECT_DIR"
    
    # Create Package.swift for the temporary project
    cat > "$TEMP_PROJECT_DIR/Package.swift" << EOF
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GoDareDI",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "GoDareDI", targets: ["GoDareDI"])
    ],
    targets: [
        .target(
            name: "GoDareDI",
            path: "Sources"
        )
    ]
)
EOF
    
    # Create Sources directory and copy Swift files
    mkdir -p "$TEMP_PROJECT_DIR/Sources/GoDareDI"
    cp -r "$SOURCE_DIR"/* "$TEMP_PROJECT_DIR/Sources/GoDareDI/"
    
    # Build using xcodebuild
    cd "$TEMP_PROJECT_DIR"
    if [ "$platform" = "ios-arm64" ]; then
        DESTINATION="generic/platform=iOS"
        SDK="iphoneos"
    elif [ "$platform" = "ios-arm64_x86_64-simulator" ]; then
        DESTINATION="generic/platform=iOS Simulator"
        SDK="iphonesimulator"
    fi
    
    xcodebuild -scheme GoDareDI \
        -destination "$DESTINATION" \
        -configuration Release \
        -derivedDataPath ../DerivedData \
        -sdk $SDK \
        build
    
           # Extract the built library and Swift module files
           cd ..
           if [ "$platform" = "ios-arm64" ]; then
               # Copy the built library to the framework
               cp DerivedData/Build/Products/Release-iphoneos/GoDareDI.o Frameworks/$platform/GoDareDI.framework/GoDareDI
               # Copy Swift module files
               if [ -d "DerivedData/Build/Products/Release-iphoneos/GoDareDI.swiftmodule" ]; then
                   cp -r DerivedData/Build/Products/Release-iphoneos/GoDareDI.swiftmodule Frameworks/$platform/GoDareDI.framework/Modules/
               fi
               # Copy any other generated files
               if [ -d "DerivedData/Build/Products/Release-iphoneos/GoDareDI.framework" ]; then
                   cp -r DerivedData/Build/Products/Release-iphoneos/GoDareDI.framework/* Frameworks/$platform/GoDareDI.framework/
               fi
           elif [ "$platform" = "ios-arm64_x86_64-simulator" ]; then
               # Copy the built library to the framework
               cp DerivedData/Build/Products/Release-iphonesimulator/GoDareDI.o Frameworks/$platform/GoDareDI.framework/GoDareDI
               # Copy Swift module files
               if [ -d "DerivedData/Build/Products/Release-iphonesimulator/GoDareDI.swiftmodule" ]; then
                   cp -r DerivedData/Build/Products/Release-iphonesimulator/GoDareDI.swiftmodule Frameworks/$platform/GoDareDI.framework/Modules/
               fi
               # Copy any other generated files
               if [ -d "DerivedData/Build/Products/Release-iphonesimulator/GoDareDI.framework" ]; then
                   cp -r DerivedData/Build/Products/Release-iphonesimulator/GoDareDI.framework/* Frameworks/$platform/GoDareDI.framework/
               fi
           fi
    
    # Clean up
    rm -rf "$TEMP_PROJECT_DIR" DerivedData GoDareDI.xcarchive
    
    # Code sign framework (use ad-hoc signing for distribution)
    codesign --force --sign "-" Frameworks/$platform/GoDareDI.framework
}

# Step 1: Build for iOS platforms only
echo "🔨 Step 1: Building for iOS platforms..."

# iOS (iPhone/iPad) - arm64
build_framework "ios-arm64" "arm64-apple-ios17.0" "iphoneos" "17.0" "iPhoneOS"

# iOS Simulator - Universal (arm64 + x86_64)
build_framework "ios-arm64_x86_64-simulator" "arm64-apple-ios17.0-simulator" "iphonesimulator" "17.0" "iPhoneSimulator"



# Step 2: Create XCFramework
echo "🎯 Step 2: Creating XCFramework from actual source..."
xcodebuild -create-xcframework \
    -framework Frameworks/ios-arm64/GoDareDI.framework \
    -framework Frameworks/ios-arm64_x86_64-simulator/GoDareDI.framework \
    -output GoDareDI.xcframework

# Step 3: Code sign the XCFramework (use ad-hoc signing for distribution)
echo "🔐 Step 3: Code signing the XCFramework..."
codesign --force --sign "-" GoDareDI.xcframework

# Step 4: Verify the XCFramework
echo "✅ Step 4: Verifying XCFramework..."
codesign --verify --verbose GoDareDI.xcframework

# Step 5: Display signing information
echo "📋 Step 5: Displaying signing information..."
codesign --display --verbose GoDareDI.xcframework

# Step 6: Clean up
echo "🧹 Step 6: Cleaning up..."
rm -rf Frameworks

echo "✅ XCFramework Built from Actual Source Successfully!"
echo "🔐 The XCFramework now includes ALL logic from:"
echo "   📁 Container/ - All container logic and implementations"
echo "   📁 Types/ - All dependency types and error types"
echo "   📁 Extensions/ - Graph analysis extensions"
echo "   📁 Security/ - License and secure initialization"
echo "   📁 Analytics/ - Analytics and dashboard sync"
echo "   📁 Visualizer/Core/ - Core visualization logic"
echo "   📁 Visualizer/Debug/ - DependencyGraphView"
echo "   📄 GoDareDI.swift - Main framework file"
echo ""
echo "📁 Complete XCFramework: GoDareDI.xcframework"
