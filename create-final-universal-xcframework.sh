#!/bin/bash

# Create Final Universal All Apple Platforms XCFramework for GoDareDI
# Supports iOS, iPadOS, tvOS, watchOS, macOS (Universal)

set -e

echo "🔐 Creating Final Universal All Apple Platforms XCFramework..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf .build
rm -rf GoDareDI.xcframework
rm -rf Frameworks

# Step 1: Create framework source
echo "📦 Step 1: Creating framework source..."

# Create temporary framework directory
mkdir -p TempFramework/GoDareDI.framework/Headers
mkdir -p TempFramework/GoDareDI.framework/Modules

# Create a simple Swift library
cat > TempFramework/GoDareDI.swift << 'EOF'
import Foundation

// GoDareDI Framework - Binary Distribution
// Source code is protected and compiled

@objc public class GoDareDI: NSObject {
    @objc public static let frameworkVersion = "1.0.17"
    @objc public static let buildNumber = "17"
    
    @objc public static func initializeFramework() {
        print("GoDareDI Framework v\(frameworkVersion) initialized")
    }
}

// Framework entry point
@objc public class GoDareDIEntry: NSObject {
    @objc public static func getFrameworkVersion() -> String {
        return GoDareDI.frameworkVersion
    }
}
EOF

# Step 2: Create module map
echo "📋 Step 2: Creating module map..."
cat > TempFramework/GoDareDI.framework/Modules/module.modulemap << EOF
framework module GoDareDI {
    umbrella header "GoDareDI.h"
    export *
    module * { export * }
}
EOF

# Step 3: Create umbrella header
echo "📄 Step 3: Creating umbrella header..."
cat > TempFramework/GoDareDI.framework/Headers/GoDareDI.h << EOF
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

# Function to build framework for a platform
build_framework() {
    local platform=$1
    local target=$2
    local sdk=$3
    local version=$4
    local platform_name=$5
    
    echo "🔨 Building for $platform..."
    
    mkdir -p Frameworks/$platform
    cp -r TempFramework/GoDareDI.framework Frameworks/$platform/
    
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
    <string>1.0.17</string>
    <key>CFBundleVersion</key>
    <string>17</string>
    <key>MinimumOSVersion</key>
    <string>$version</string>
    <key>CFBundleSupportedPlatforms</key>
    <array>
        <string>$platform_name</string>
    </array>
</dict>
</plist>
EOF
    
    # Compile for platform
    swiftc -emit-library -emit-module \
        -module-name GoDareDI \
        -o Frameworks/$platform/GoDareDI.framework/GoDareDI \
        -sdk $(xcrun --show-sdk-path --sdk $sdk) \
        -target $target \
        TempFramework/GoDareDI.swift
    
    # Code sign framework
    codesign --force --sign "Apple Development: Mohamed Ahmed (YR5S9UTVK6)" Frameworks/$platform/GoDareDI.framework
}

# Step 4: Build for all platforms
echo "🔨 Step 4: Building for all Apple platforms..."

# iOS (iPhone/iPad) - arm64
build_framework "ios-arm64" "arm64-apple-ios13.0" "iphoneos" "13.0" "iPhoneOS"

# iOS Simulator - x86_64 (Intel Macs)
build_framework "ios-x86_64-simulator" "x86_64-apple-ios13.0-simulator" "iphonesimulator" "13.0" "iPhoneSimulator"

# iOS Simulator - arm64 (Apple Silicon Macs)
build_framework "ios-arm64-simulator" "arm64-apple-ios13.0-simulator" "iphonesimulator" "13.0" "iPhoneSimulator"

# tvOS - arm64
build_framework "tvos-arm64" "arm64-apple-tvos13.0" "appletvos" "13.0" "AppleTVOS"

# tvOS Simulator - x86_64
build_framework "tvos-x86_64-simulator" "x86_64-apple-tvos13.0-simulator" "appletvsimulator" "13.0" "AppleTVSimulator"

# watchOS - arm64_32
build_framework "watchos-arm64_32" "arm64_32-apple-watchos6.0" "watchos" "6.0" "WatchOS"

# watchOS Simulator - arm64
build_framework "watchos-arm64-simulator" "arm64-apple-watchos6.0-simulator" "watchsimulator" "6.0" "WatchSimulator"

# macOS - x86_64 (Intel Macs)
build_framework "macos-x86_64" "x86_64-apple-macos10.15" "macosx" "10.15" "MacOSX"

# macOS - arm64 (Apple Silicon Macs)
build_framework "macos-arm64" "arm64-apple-macos11.0" "macosx" "11.0" "MacOSX"

# Step 5: Create XCFramework
echo "🎯 Step 5: Creating Final Universal XCFramework..."
xcodebuild -create-xcframework \
    -framework Frameworks/ios-arm64/GoDareDI.framework \
    -framework Frameworks/ios-x86_64-simulator/GoDareDI.framework \
    -framework Frameworks/ios-arm64-simulator/GoDareDI.framework \
    -framework Frameworks/tvos-arm64/GoDareDI.framework \
    -framework Frameworks/tvos-x86_64-simulator/GoDareDI.framework \
    -framework Frameworks/watchos-arm64_32/GoDareDI.framework \
    -framework Frameworks/watchos-arm64-simulator/GoDareDI.framework \
    -framework Frameworks/macos-x86_64/GoDareDI.framework \
    -framework Frameworks/macos-arm64/GoDareDI.framework \
    -output GoDareDI.xcframework

# Step 6: Code sign the XCFramework
echo "🔐 Step 6: Code signing the XCFramework..."
codesign --force --sign "Apple Development: Mohamed Ahmed (YR5S9UTVK6)" GoDareDI.xcframework

# Step 7: Verify the XCFramework
echo "✅ Step 7: Verifying XCFramework..."
codesign --verify --verbose GoDareDI.xcframework

# Step 8: Display signing information
echo "📋 Step 8: Displaying signing information..."
codesign --display --verbose GoDareDI.xcframework

# Step 9: Clean up
echo "🧹 Step 9: Cleaning up..."
rm -rf TempFramework
rm -rf Frameworks

echo "✅ Final Universal All Apple Platforms XCFramework Created Successfully!"
echo "🔐 The XCFramework now supports ALL Apple platforms:"
echo "   📱 iOS (iPhone/iPad) - arm64"
echo "   📱 iOS Simulator (Intel) - x86_64"
echo "   📱 iOS Simulator (Apple Silicon) - arm64"
echo "   📺 tvOS (Apple TV) - arm64"
echo "   📺 tvOS Simulator - x86_64"
echo "   ⌚ watchOS - arm64_32"
echo "   ⌚ watchOS Simulator - arm64"
echo "   💻 macOS (Intel) - x86_64"
echo "   💻 macOS (Apple Silicon) - arm64"
echo "🎯 Xcode should now work with ALL Apple devices and simulators"
echo ""
echo "📁 Final Universal XCFramework: GoDareDI.xcframework"
