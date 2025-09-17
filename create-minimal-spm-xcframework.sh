#!/bin/bash

set -e

echo "🔨 Creating minimal SPM-compatible GODareDI XCFramework..."

FRAMEWORK_NAME="GODareDI"
VERSION="2.0.6"
OUTPUT_DIR="${FRAMEWORK_NAME}.xcframework"
TEMP_DIR="temp_minimal"

# Clean and recreate directories
echo "🧹 Cleaning previous builds..."
rm -rf "$OUTPUT_DIR"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# Create XCFramework structure
echo "📁 Creating XCFramework structure..."
mkdir -p "$OUTPUT_DIR/ios-arm64/$FRAMEWORK_NAME.framework"
mkdir -p "$OUTPUT_DIR/ios-arm64-simulator/$FRAMEWORK_NAME.framework"

# Create framework directories
mkdir -p "$OUTPUT_DIR/ios-arm64/$FRAMEWORK_NAME.framework/Headers"
mkdir -p "$OUTPUT_DIR/ios-arm64/$FRAMEWORK_NAME.framework/Modules"
mkdir -p "$OUTPUT_DIR/ios-arm64-simulator/$FRAMEWORK_NAME.framework/Headers"
mkdir -p "$OUTPUT_DIR/ios-arm64-simulator/$FRAMEWORK_NAME.framework/Modules"

# Create umbrella header
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

# Copy header to simulator
cp "$OUTPUT_DIR/ios-arm64/$FRAMEWORK_NAME.framework/Headers/$FRAMEWORK_NAME.h" \
   "$OUTPUT_DIR/ios-arm64-simulator/$FRAMEWORK_NAME.framework/Headers/$FRAMEWORK_NAME.h"

# Create module.modulemap
echo "📝 Creating module.modulemap..."
cat > "$OUTPUT_DIR/ios-arm64/$FRAMEWORK_NAME.framework/Modules/module.modulemap" << EOF
framework module $FRAMEWORK_NAME {
    umbrella header "$FRAMEWORK_NAME.h"
    
    export *
    module * { export * }
    
    link framework "Foundation"
}
EOF

# Copy module map to simulator
cp "$OUTPUT_DIR/ios-arm64/$FRAMEWORK_NAME.framework/Modules/module.modulemap" \
   "$OUTPUT_DIR/ios-arm64-simulator/$FRAMEWORK_NAME.framework/Modules/module.modulemap"

# Create Info.plist files for each platform
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

# Copy Info.plist to simulator
cp "$OUTPUT_DIR/ios-arm64/$FRAMEWORK_NAME.framework/Info.plist" \
   "$OUTPUT_DIR/ios-arm64-simulator/$FRAMEWORK_NAME.framework/Info.plist"

# Update simulator Info.plist
sed -i '' 's/iPhoneOS/iPhoneSimulator/g' "$OUTPUT_DIR/ios-arm64-simulator/$FRAMEWORK_NAME.framework/Info.plist"
sed -i '' 's/iphoneos/iphonesimulator/g' "$OUTPUT_DIR/ios-arm64-simulator/$FRAMEWORK_NAME.framework/Info.plist"

# Create a simple C source file for compilation
echo "🔧 Creating simple C source..."
cat > "$TEMP_DIR/godare_source.c" << 'EOF'
#include <stdio.h>

void godare_init() {
    printf("GODareDI Framework Initialized\n");
}

int godare_version() {
    return 206; // Version 2.0.6
}
EOF

# Compile for iOS device (dynamic library)
echo "📱 Compiling for iOS device..."
clang -shared -target arm64-apple-ios13.0 \
    -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk \
    -miphoneos-version-min=13.0 \
    -install_name @rpath/GODareDI.framework/GODareDI \
    -compatibility_version 1.0 \
    -current_version 1.0 \
    -o "$TEMP_DIR/ios-arm64.dylib" \
    "$TEMP_DIR/godare_source.c"

# Compile for iOS simulator (dynamic library)
echo "📱 Compiling for iOS simulator..."
clang -shared -target arm64-apple-ios13.0-simulator \
    -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk \
    -miphoneos-version-min=13.0 \
    -install_name @rpath/GODareDI.framework/GODareDI \
    -compatibility_version 1.0 \
    -current_version 1.0 \
    -o "$TEMP_DIR/ios-arm64-simulator.dylib" \
    "$TEMP_DIR/godare_source.c"

# Copy dynamic libraries to frameworks
cp "$TEMP_DIR/ios-arm64.dylib" "$OUTPUT_DIR/ios-arm64/$FRAMEWORK_NAME.framework/$FRAMEWORK_NAME"
cp "$TEMP_DIR/ios-arm64-simulator.dylib" "$OUTPUT_DIR/ios-arm64-simulator/$FRAMEWORK_NAME.framework/$FRAMEWORK_NAME"

# Create XCFramework Info.plist
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

# Verify the XCFramework
if [ -d "$OUTPUT_DIR" ]; then
    echo "✅ $FRAMEWORK_NAME.xcframework created successfully!"
    echo "📁 Location: $(pwd)/$OUTPUT_DIR"
    
    # List contents
    echo "📋 Contents:"
    find "$OUTPUT_DIR" -type f | head -20
    
    # Check binary sizes
    echo "📊 Binary sizes:"
    find "$OUTPUT_DIR" -name "$FRAMEWORK_NAME" -exec ls -lh {} \;
    
    # Verify binary types
    echo "🔍 Binary types:"
    find "$OUTPUT_DIR" -name "$FRAMEWORK_NAME" -exec file {} \;
    
else
    echo "❌ XCFramework was not created"
    exit 1
fi

# Clean up
echo "🧹 Cleaning up..."
rm -rf "$TEMP_DIR"

echo "🎉 Minimal SPM-compatible XCFramework created successfully!"
echo "📦 XCFramework ready for SPM distribution"
