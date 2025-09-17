#!/bin/bash
set -e

FRAMEWORK_NAME="GODareDI"
OUTPUT_DIR="GODareDI.xcframework"
TEMP_DIR="temp_swift_build"
VERSION="2.0.8" # Updated version
SOURCE_DIR="../Sources/GoDareDI"

echo "🔨 Creating full Swift XCFramework for $FRAMEWORK_NAME..."

# 1. Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf "$TEMP_DIR" "$OUTPUT_DIR" DerivedData

# 2. Create XCFramework structure
echo "📁 Creating XCFramework structure..."
mkdir -p "$OUTPUT_DIR/ios-arm64/$FRAMEWORK_NAME.framework/Headers"
mkdir -p "$OUTPUT_DIR/ios-arm64/$FRAMEWORK_NAME.framework/Modules"
mkdir -p "$OUTPUT_DIR/ios-arm64-simulator/$FRAMEWORK_NAME.framework/Headers"
mkdir -p "$OUTPUT_DIR/ios-arm64-simulator/$FRAMEWORK_NAME.framework/Modules"

# 3. Create umbrella header
echo "📝 Creating umbrella header..."
cat > "$OUTPUT_DIR/ios-arm64/$FRAMEWORK_NAME.framework/Headers/$FRAMEWORK_NAME.h" << 'EOF'
#ifndef GODareDI_h
#define GODareDI_h

#import <Foundation/Foundation.h>

//! Project version number for GODareDI.
FOUNDATION_EXPORT double GODareDIVersionNumber;

//! Project version string for GODareDI.
FOUNDATION_EXPORT const unsigned char GODareDIVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <GODareDI/PublicHeader.h>

// GODareDI Framework
// This is a binary framework - source code is protected

// Core DI Types
@protocol AdvancedDIContainer <NSObject>
@end

// Dependency Scopes
typedef NS_ENUM(NSInteger, DependencyScope) {
    DependencyScopeSingleton = 0,
    DependencyScopeScoped = 1,
    DependencyScopeTransient = 2,
    DependencyScopeLazy = 3
};

// Dependency Lifetimes
typedef NS_ENUM(NSInteger, DependencyLifetime) {
    DependencyLifetimeApplication = 0,
    DependencyLifetimeSession = 1,
    DependencyLifetimeRequest = 2,
    DependencyLifetimeCustom = 3
};

// Main initialization function
void godare_init(void);
int godare_version(void);

#endif /* GODareDI_h */
EOF
cp "$OUTPUT_DIR/ios-arm64/$FRAMEWORK_NAME.framework/Headers/$FRAMEWORK_NAME.h" "$OUTPUT_DIR/ios-arm64-simulator/$FRAMEWORK_NAME.framework/Headers/$FRAMEWORK_NAME.h"

# 4. Create module.modulemap
echo "📝 Creating module.modulemap..."
cat > "$OUTPUT_DIR/ios-arm64/$FRAMEWORK_NAME.framework/Modules/module.modulemap" << EOF
framework module $FRAMEWORK_NAME {
    umbrella header "$FRAMEWORK_NAME.h"
    export *
    module * { export * }
    link framework "Foundation"
}
EOF
cp "$OUTPUT_DIR/ios-arm64/$FRAMEWORK_NAME.framework/Modules/module.modulemap" "$OUTPUT_DIR/ios-arm64-simulator/$FRAMEWORK_NAME.framework/Modules/module.modulemap"

# 5. Create Info.plist files for each platform
echo "📝 Creating Info.plist files..."
cat > "$OUTPUT_DIR/ios-arm64/$FRAMEWORK_NAME.framework/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$FRAMEWORK_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.godare.$FRAMEWORK_NAME</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$FRAMEWORK_NAME</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>MinimumOSVersion</key>
    <string>13.0</string>
    <key>CFBundleSupportedPlatforms</key>
    <array>
        <string>iPhoneOS</string>
    </array>
    <key>DTPlatformName</key>
    <string>iphoneos</string>
    <key>DTSDKName</key>
    <string>iphoneos</string>
</dict>
</plist>
EOF
cp "$OUTPUT_DIR/ios-arm64/$FRAMEWORK_NAME.framework/Info.plist" "$OUTPUT_DIR/ios-arm64-simulator/$FRAMEWORK_NAME.framework/Info.plist"

# Update simulator Info.plist
sed -i '' 's/iPhoneOS/iPhoneSimulator/g' "$OUTPUT_DIR/ios-arm64-simulator/$FRAMEWORK_NAME.framework/Info.plist"
sed -i '' 's/iphoneos/iphonesimulator/g' "$OUTPUT_DIR/ios-arm64-simulator/$FRAMEWORK_NAME.framework/Info.plist"

# 6. Build Swift source code for iOS device
echo "📱 Building Swift source for iOS device..."
mkdir -p "$TEMP_DIR/ios-arm64"

# Create a temporary Package.swift for building
cat > "$TEMP_DIR/Package.swift" << 'EOF'
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GODareDI",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "GODareDI",
            targets: ["GODareDI"]
        ),
    ],
    targets: [
        .target(
            name: "GODareDI",
            path: "Sources/GoDareDI"
        ),
    ]
)
EOF

# Copy source files
cp -r "$SOURCE_DIR" "$TEMP_DIR/Sources/"

# Build for iOS device
cd "$TEMP_DIR"
swift build -c release --arch arm64-apple-ios13.0
cd ..

# 7. Build Swift source code for iOS simulator
echo "📱 Building Swift source for iOS simulator..."
mkdir -p "$TEMP_DIR/ios-arm64-simulator"

# Build for iOS simulator
cd "$TEMP_DIR"
swift build -c release --arch arm64-apple-ios13.0-simulator
cd ..

# 8. Extract and copy Swift modules
echo "📦 Extracting Swift modules..."

# For iOS device
if [ -d "$TEMP_DIR/.build/arm64-apple-ios13.0/release" ]; then
    cp -r "$TEMP_DIR/.build/arm64-apple-ios13.0/release"/* "$OUTPUT_DIR/ios-arm64/$FRAMEWORK_NAME.framework/"
fi

# For iOS simulator
if [ -d "$TEMP_DIR/.build/arm64-apple-ios13.0-simulator/release" ]; then
    cp -r "$TEMP_DIR/.build/arm64-apple-ios13.0-simulator/release"/* "$OUTPUT_DIR/ios-arm64-simulator/$FRAMEWORK_NAME.framework/"
fi

# 9. Create Swift interface files
echo "📝 Creating Swift interface files..."

# Create .swiftinterface files for both platforms
mkdir -p "$OUTPUT_DIR/ios-arm64/$FRAMEWORK_NAME.framework/Modules/$FRAMEWORK_NAME.swiftmodule"
mkdir -p "$OUTPUT_DIR/ios-arm64-simulator/$FRAMEWORK_NAME.framework/Modules/$FRAMEWORK_NAME.swiftmodule"

# Generate interface files using swiftc
swiftc -emit-module-interface \
    -target arm64-apple-ios13.0 \
    -sdk "$(xcrun --sdk iphoneos --show-sdk-path)" \
    -module-name "$FRAMEWORK_NAME" \
    -o "$OUTPUT_DIR/ios-arm64/$FRAMEWORK_NAME.framework/Modules/$FRAMEWORK_NAME.swiftmodule/arm64-apple-ios13.0.swiftinterface" \
    "$SOURCE_DIR"/*.swift

swiftc -emit-module-interface \
    -target arm64-apple-ios13.0-simulator \
    -sdk "$(xcrun --sdk iphonesimulator --show-sdk-path)" \
    -module-name "$FRAMEWORK_NAME" \
    -o "$OUTPUT_DIR/ios-arm64-simulator/$FRAMEWORK_NAME.framework/Modules/$FRAMEWORK_NAME.swiftmodule/arm64-apple-ios13.0-simulator.swiftinterface" \
    "$SOURCE_DIR"/*.swift

# 10. Create XCFramework Info.plist
echo "📝 Creating XCFramework Info.plist..."
cat > "$OUTPUT_DIR/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>AvailableLibraries</key>
    <array>
        <dict>
            <key>LibraryIdentifier</key>
            <string>ios-arm64</string>
            <key>LibraryPath</key>
            <string>$FRAMEWORK_NAME.framework</string>
            <key>HeadersPath</key>
            <string>Headers</string>
            <key>Platform</key>
            <string>ios</string>
            <key>SupportedArchitectures</key>
            <array>
                <string>arm64</string>
            </array>
            <key>SupportedPlatformVariant</key>
            <string>device</string>
        </dict>
        <dict>
            <key>LibraryIdentifier</key>
            <string>ios-arm64-simulator</string>
            <key>LibraryPath</key>
            <string>$FRAMEWORK_NAME.framework</string>
            <key>HeadersPath</key>
            <string>Headers</string>
            <key>Platform</key>
            <string>ios</string>
            <key>SupportedArchitectures</key>
            <array>
                <string>arm64</string>
            </array>
            <key>SupportedPlatformVariant</key>
            <string>simulator</string>
        </dict>
    </array>
    <key>CFBundlePackageType</key>
    <string>XFWK</string>
    <key>XCFrameworkFormatVersion</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>$FRAMEWORK_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.godare.$FRAMEWORK_NAME</string>
    <key>CFBundleName</key>
    <string>$FRAMEWORK_NAME</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>1</string>
</dict>
</plist>
EOF

echo "✅ $FRAMEWORK_NAME.xcframework created successfully!"
echo "📁 Location: $(pwd)/$OUTPUT_DIR"

# 11. Verify contents
echo "📋 Contents:"
ls -R "$OUTPUT_DIR"

# 12. Clean up temporary files
echo "🧹 Cleaning up..."
rm -rf "$TEMP_DIR"

echo "🎉 Full Swift XCFramework created successfully!"
echo "📦 XCFramework ready for SPM distribution with complete Swift API"
