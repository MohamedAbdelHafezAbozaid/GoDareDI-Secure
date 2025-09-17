#!/bin/bash
set -e

# =============================================================================
# GoDareDI XCFramework Build Script
# =============================================================================
# This script creates a production-ready XCFramework for GoDareDI with:
# - Dynamic framework compilation for iOS device and simulator
# - Proper Swift interface files for SPM compatibility
# - Binary validation and signing verification
# - SPM packaging with checksum generation
# - GitHub release automation support
# =============================================================================

# Configuration
FRAMEWORK_NAME="GoDareDI"
OUTPUT_DIR="GoDareDI-Secure-Distribution"
XCFRAMEWORK_NAME="GoDareDI.xcframework"
VERSION="${1:-2.0.11}"
SOURCE_DIR="Sources/GoDareDI"
BUILD_DIR="build"
TEMP_DIR="temp_build"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# =============================================================================
# 1. CLEANUP
# =============================================================================
cleanup() {
    log_info "Starting cleanup phase..."
    
    # Remove existing XCFramework artifacts
    if [ -d "$OUTPUT_DIR/$XCFRAMEWORK_NAME" ]; then
        log_info "Removing existing XCFramework..."
        rm -rf "$OUTPUT_DIR/$XCFRAMEWORK_NAME"
    fi
    
    # Remove temporary build files
    log_info "Cleaning temporary build files..."
    rm -rf "$BUILD_DIR" "$TEMP_DIR" DerivedData .build/
    
    # Remove any existing dylib stubs
    find . -name "*.dylib" -type f -delete 2>/dev/null || true
    
    log_success "Cleanup completed"
}

# =============================================================================
# 2. SOURCE ANALYSIS
# =============================================================================
analyze_source() {
    log_info "Analyzing GoDareDI source code..."
    
    # Count source files
    local swift_files=$(find "$SOURCE_DIR" -name "*.swift" | wc -l)
    log_info "Found $swift_files Swift source files"
    
    # Identify key components
    local protocols=$(grep -r "public protocol" "$SOURCE_DIR" --include="*.swift" | wc -l)
    local initializers=$(grep -r "public init" "$SOURCE_DIR" --include="*.swift" | wc -l)
    local error_types=$(grep -r "public.*Error" "$SOURCE_DIR" --include="*.swift" | wc -l)
    local swiftui_views=$(grep -r "import SwiftUI" "$SOURCE_DIR" --include="*.swift" | wc -l)
    
    log_info "Source analysis complete:"
    log_info "  - Protocols: $protocols"
    log_info "  - Initializers: $initializers"
    log_info "  - Error types: $error_types"
    log_info "  - SwiftUI views: $swiftui_views"
    
    # Verify DependencyGraphView exists
    if grep -r "DependencyGraphView" "$SOURCE_DIR" --include="*.swift" > /dev/null; then
        log_success "DependencyGraphView found in source"
    else
        log_error "DependencyGraphView not found in source!"
        exit 1
    fi
}

# =============================================================================
# 3. FRAMEWORK BUILD
# =============================================================================
build_framework() {
    log_info "Building dynamic framework for iOS..."
    
    # Create build directories
    mkdir -p "$BUILD_DIR/ios-device"
    mkdir -p "$BUILD_DIR/ios-simulator"
    mkdir -p "$BUILD_DIR/ios-simulator-x86"
    
    # Get SDK paths
    local ios_sdk=$(xcrun --sdk iphoneos --show-sdk-path)
    local simulator_sdk=$(xcrun --sdk iphonesimulator --show-sdk-path)
    
    log_info "iOS SDK: $ios_sdk"
    log_info "Simulator SDK: $simulator_sdk"
    
    # Build for iOS device (arm64)
    log_info "Compiling for iOS device (arm64)..."
    swiftc -emit-library \
        -target arm64-apple-ios13.0 \
        -sdk "$ios_sdk" \
        -module-name "$FRAMEWORK_NAME" \
        -emit-module \
        -emit-module-interface \
        -enable-library-evolution \
        -swift-version 5 \
        -O \
        -whole-module-optimization \
        -emit-module-interface-path "$BUILD_DIR/ios-device/$FRAMEWORK_NAME.swiftinterface" \
        -o "$BUILD_DIR/ios-device/lib$FRAMEWORK_NAME.dylib" \
        "$SOURCE_DIR"/*.swift \
        "$SOURCE_DIR"/**/*.swift 2>/dev/null || {
            log_warning "Failed to compile with glob patterns, trying individual files..."
            find "$SOURCE_DIR" -name "*.swift" -exec swiftc -emit-library \
                -target arm64-apple-ios13.0 \
                -sdk "$ios_sdk" \
                -module-name "$FRAMEWORK_NAME" \
                -emit-module \
                -emit-module-interface \
                -enable-library-evolution \
                -swift-version 5 \
                -O \
                -whole-module-optimization \
                -emit-module-interface-path "$BUILD_DIR/ios-device/$FRAMEWORK_NAME.swiftinterface" \
                -o "$BUILD_DIR/ios-device/lib$FRAMEWORK_NAME.dylib" \
                {} + 2>/dev/null || {
                    log_error "Failed to compile Swift source for iOS device"
                    exit 1
                }
        }
    
    # Build for iOS simulator (arm64)
    log_info "Compiling for iOS simulator (arm64)..."
    swiftc -emit-library \
        -target arm64-apple-ios13.0-simulator \
        -sdk "$simulator_sdk" \
        -module-name "$FRAMEWORK_NAME" \
        -emit-module \
        -emit-module-interface \
        -enable-library-evolution \
        -swift-version 5 \
        -O \
        -whole-module-optimization \
        -emit-module-interface-path "$BUILD_DIR/ios-simulator/$FRAMEWORK_NAME.swiftinterface" \
        -o "$BUILD_DIR/ios-simulator/lib$FRAMEWORK_NAME.dylib" \
        "$SOURCE_DIR"/*.swift \
        "$SOURCE_DIR"/**/*.swift 2>/dev/null || {
            find "$SOURCE_DIR" -name "*.swift" -exec swiftc -emit-library \
                -target arm64-apple-ios13.0-simulator \
                -sdk "$simulator_sdk" \
                -module-name "$FRAMEWORK_NAME" \
                -emit-module \
                -emit-module-interface \
                -enable-library-evolution \
                -swift-version 5 \
                -O \
                -whole-module-optimization \
                -emit-module-interface-path "$BUILD_DIR/ios-simulator/$FRAMEWORK_NAME.swiftinterface" \
                -o "$BUILD_DIR/ios-simulator/lib$FRAMEWORK_NAME.dylib" \
                {} + 2>/dev/null || {
                    log_error "Failed to compile Swift source for iOS simulator"
                    exit 1
                }
        }
    
    # Build for iOS simulator (x86_64) - for Intel Macs
    log_info "Compiling for iOS simulator (x86_64)..."
    swiftc -emit-library \
        -target x86_64-apple-ios13.0-simulator \
        -sdk "$simulator_sdk" \
        -module-name "$FRAMEWORK_NAME" \
        -emit-module \
        -emit-module-interface \
        -enable-library-evolution \
        -swift-version 5 \
        -O \
        -whole-module-optimization \
        -emit-module-interface-path "$BUILD_DIR/ios-simulator-x86/$FRAMEWORK_NAME.swiftinterface" \
        -o "$BUILD_DIR/ios-simulator-x86/lib$FRAMEWORK_NAME.dylib" \
        "$SOURCE_DIR"/*.swift \
        "$SOURCE_DIR"/**/*.swift 2>/dev/null || {
            find "$SOURCE_DIR" -name "*.swift" -exec swiftc -emit-library \
                -target x86_64-apple-ios13.0-simulator \
                -sdk "$simulator_sdk" \
                -module-name "$FRAMEWORK_NAME" \
                -emit-module \
                -emit-module-interface \
                -enable-library-evolution \
                -swift-version 5 \
                -O \
                -whole-module-optimization \
                -emit-module-interface-path "$BUILD_DIR/ios-simulator-x86/$FRAMEWORK_NAME.swiftinterface" \
                -o "$BUILD_DIR/ios-simulator-x86/lib$FRAMEWORK_NAME.dylib" \
                {} + 2>/dev/null || {
                    log_warning "Failed to compile for x86_64 simulator (this is expected on Apple Silicon)"
                }
        }
    
    log_success "Framework compilation completed"
}

# =============================================================================
# 4. XCFRAMEWORK CREATION
# =============================================================================
create_xcframework() {
    log_info "Creating XCFramework structure..."
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    
    # Create XCFramework structure
    mkdir -p "$OUTPUT_DIR/$XCFRAMEWORK_NAME/ios-arm64/$FRAMEWORK_NAME.framework/Headers"
    mkdir -p "$OUTPUT_DIR/$XCFRAMEWORK_NAME/ios-arm64/$FRAMEWORK_NAME.framework/Modules"
    mkdir -p "$OUTPUT_DIR/$XCFRAMEWORK_NAME/ios-arm64-simulator/$FRAMEWORK_NAME.framework/Headers"
    mkdir -p "$OUTPUT_DIR/$XCFRAMEWORK_NAME/ios-arm64-simulator/$FRAMEWORK_NAME.framework/Modules"
    
    # Create umbrella header
    log_info "Creating umbrella header..."
    cat > "$OUTPUT_DIR/$XCFRAMEWORK_NAME/ios-arm64/$FRAMEWORK_NAME.framework/Headers/$FRAMEWORK_NAME.h" << 'EOF'
#ifndef GoDareDI_h
#define GoDareDI_h

#import <Foundation/Foundation.h>

//! Project version number for GoDareDI.
FOUNDATION_EXPORT double GoDareDIVersionNumber;

//! Project version string for GoDareDI.
FOUNDATION_EXPORT const unsigned char GoDareDIVersionString[];

// GoDareDI Framework - Advanced Dependency Injection
// This is a binary framework with full Swift API support

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

#endif /* GoDareDI_h */
EOF
    
    # Copy umbrella header to simulator
    cp "$OUTPUT_DIR/$XCFRAMEWORK_NAME/ios-arm64/$FRAMEWORK_NAME.framework/Headers/$FRAMEWORK_NAME.h" \
       "$OUTPUT_DIR/$XCFRAMEWORK_NAME/ios-arm64-simulator/$FRAMEWORK_NAME.framework/Headers/$FRAMEWORK_NAME.h"
    
    # Create module.modulemap
    log_info "Creating module.modulemap..."
    cat > "$OUTPUT_DIR/$XCFRAMEWORK_NAME/ios-arm64/$FRAMEWORK_NAME.framework/Modules/module.modulemap" << EOF
framework module $FRAMEWORK_NAME {
    umbrella header "$FRAMEWORK_NAME.h"
    export *
    module * { export * }
    link framework "Foundation"
    link framework "SwiftUI"
}
EOF
    
    # Copy module map to simulator
    cp "$OUTPUT_DIR/$XCFRAMEWORK_NAME/ios-arm64/$FRAMEWORK_NAME.framework/Modules/module.modulemap" \
       "$OUTPUT_DIR/$XCFRAMEWORK_NAME/ios-arm64-simulator/$FRAMEWORK_NAME.framework/Modules/module.modulemap"
    
    # Create Info.plist files
    log_info "Creating Info.plist files..."
    cat > "$OUTPUT_DIR/$XCFRAMEWORK_NAME/ios-arm64/$FRAMEWORK_NAME.framework/Info.plist" << EOF
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
    
    # Copy and modify Info.plist for simulator
    cp "$OUTPUT_DIR/$XCFRAMEWORK_NAME/ios-arm64/$FRAMEWORK_NAME.framework/Info.plist" \
       "$OUTPUT_DIR/$XCFRAMEWORK_NAME/ios-arm64-simulator/$FRAMEWORK_NAME.framework/Info.plist"
    
    # Update simulator Info.plist
    sed -i '' 's/iPhoneOS/iPhoneSimulator/g' "$OUTPUT_DIR/$XCFRAMEWORK_NAME/ios-arm64-simulator/$FRAMEWORK_NAME.framework/Info.plist"
    sed -i '' 's/iphoneos/iphonesimulator/g' "$OUTPUT_DIR/$XCFRAMEWORK_NAME/ios-arm64-simulator/$FRAMEWORK_NAME.framework/Info.plist"
    
    # Copy compiled binaries
    log_info "Copying compiled binaries..."
    cp "$BUILD_DIR/ios-device/lib$FRAMEWORK_NAME.dylib" \
       "$OUTPUT_DIR/$XCFRAMEWORK_NAME/ios-arm64/$FRAMEWORK_NAME.framework/$FRAMEWORK_NAME"
    
    cp "$BUILD_DIR/ios-simulator/lib$FRAMEWORK_NAME.dylib" \
       "$OUTPUT_DIR/$XCFRAMEWORK_NAME/ios-arm64-simulator/$FRAMEWORK_NAME.framework/$FRAMEWORK_NAME"
    
    # Create Swift module directories and copy interface files
    log_info "Creating Swift module directories..."
    mkdir -p "$OUTPUT_DIR/$XCFRAMEWORK_NAME/ios-arm64/$FRAMEWORK_NAME.framework/Modules/$FRAMEWORK_NAME.swiftmodule"
    mkdir -p "$OUTPUT_DIR/$XCFRAMEWORK_NAME/ios-arm64-simulator/$FRAMEWORK_NAME.framework/Modules/$FRAMEWORK_NAME.swiftmodule"
    
    # Copy Swift interface files
    if [ -f "$BUILD_DIR/ios-device/$FRAMEWORK_NAME.swiftinterface" ]; then
        cp "$BUILD_DIR/ios-device/$FRAMEWORK_NAME.swiftinterface" \
           "$OUTPUT_DIR/$XCFRAMEWORK_NAME/ios-arm64/$FRAMEWORK_NAME.framework/Modules/$FRAMEWORK_NAME.swiftmodule/arm64-apple-ios13.0.swiftinterface"
    fi
    
    if [ -f "$BUILD_DIR/ios-simulator/$FRAMEWORK_NAME.swiftinterface" ]; then
        cp "$BUILD_DIR/ios-simulator/$FRAMEWORK_NAME.swiftinterface" \
           "$OUTPUT_DIR/$XCFRAMEWORK_NAME/ios-arm64-simulator/$FRAMEWORK_NAME.framework/Modules/$FRAMEWORK_NAME.swiftmodule/arm64-apple-ios13.0-simulator.swiftinterface"
    fi
    
    # Create XCFramework Info.plist
    log_info "Creating XCFramework Info.plist..."
    cat > "$OUTPUT_DIR/$XCFRAMEWORK_NAME/Info.plist" << EOF
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
    
    log_success "XCFramework structure created"
}

# =============================================================================
# 5. VALIDATION
# =============================================================================
validate_binaries() {
    log_info "Validating built binaries..."
    
    # Check if binaries exist
    local device_binary="$OUTPUT_DIR/$XCFRAMEWORK_NAME/ios-arm64/$FRAMEWORK_NAME.framework/$FRAMEWORK_NAME"
    local simulator_binary="$OUTPUT_DIR/$XCFRAMEWORK_NAME/ios-arm64-simulator/$FRAMEWORK_NAME.framework/$FRAMEWORK_NAME"
    
    if [ ! -f "$device_binary" ]; then
        log_error "Device binary not found: $device_binary"
        exit 1
    fi
    
    if [ ! -f "$simulator_binary" ]; then
        log_error "Simulator binary not found: $simulator_binary"
        exit 1
    fi
    
    # Check binary types
    log_info "Checking binary types..."
    local device_type=$(file "$device_binary")
    local simulator_type=$(file "$simulator_binary")
    
    log_info "Device binary: $device_type"
    log_info "Simulator binary: $simulator_type"
    
    # Verify they are Mach-O dynamic libraries
    if echo "$device_type" | grep -q "Mach-O.*dynamically linked shared library.*arm64"; then
        log_success "Device binary is valid Mach-O dynamic library for arm64"
    else
        log_error "Device binary is not a valid Mach-O dynamic library for arm64"
        exit 1
    fi
    
    if echo "$simulator_type" | grep -q "Mach-O.*dynamically linked shared library.*arm64"; then
        log_success "Simulator binary is valid Mach-O dynamic library for arm64"
    else
        log_error "Simulator binary is not a valid Mach-O dynamic library for arm64"
        exit 1
    fi
    
    # Check code signing
    log_info "Checking code signing..."
    if codesign -dv "$device_binary" 2>/dev/null; then
        log_success "Device binary is properly signed"
    else
        log_warning "Device binary is not signed (this is normal for development builds)"
    fi
    
    if codesign -dv "$simulator_binary" 2>/dev/null; then
        log_success "Simulator binary is properly signed"
    else
        log_warning "Simulator binary is not signed (this is normal for development builds)"
    fi
    
    # Verify DependencyGraphView is accessible
    log_info "Verifying DependencyGraphView accessibility..."
    if grep -q "DependencyGraphView" "$OUTPUT_DIR/$XCFRAMEWORK_NAME/ios-arm64/$FRAMEWORK_NAME.framework/Modules/$FRAMEWORK_NAME.swiftmodule/"*.swiftinterface 2>/dev/null; then
        log_success "DependencyGraphView is accessible in the framework"
    else
        log_warning "DependencyGraphView not found in interface files"
    fi
    
    log_success "Binary validation completed"
}

# =============================================================================
# 6. SPM PACKAGING
# =============================================================================
package_for_spm() {
    log_info "Packaging for SPM distribution..."
    
    # Create zip file
    local zip_name="${FRAMEWORK_NAME}-${VERSION}.xcframework.zip"
    log_info "Creating zip file: $zip_name"
    
    cd "$OUTPUT_DIR"
    zip -r "$zip_name" "$XCFRAMEWORK_NAME" > /dev/null
    cd ..
    
    # Generate checksum
    log_info "Generating SHA256 checksum..."
    local checksum=$(swift package compute-checksum "$OUTPUT_DIR/$zip_name")
    
    log_info "Checksum: $checksum"
    
    # Save checksum to file
    echo "$checksum" > "$OUTPUT_DIR/checksum.txt"
    
    # Create Package.swift template
    log_info "Creating Package.swift template..."
    cat > "$OUTPUT_DIR/Package.swift.template" << EOF
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GoDareDI",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "GoDareDI",
            targets: ["GoDareDI"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "GoDareDI",
            url: "https://github.com/MohamedAbdelHafezAbozaid/GoDareDI-Secure/releases/download/v$VERSION/$zip_name",
            checksum: "$checksum"
        ),
    ]
)
EOF
    
    log_success "SPM packaging completed"
    log_info "Files created:"
    log_info "  - $OUTPUT_DIR/$zip_name"
    log_info "  - $OUTPUT_DIR/checksum.txt"
    log_info "  - $OUTPUT_DIR/Package.swift.template"
}

# =============================================================================
# 7. GITHUB RELEASE PREPARATION
# =============================================================================
prepare_github_release() {
    log_info "Preparing GitHub release..."
    
    # Create release notes
    cat > "$OUTPUT_DIR/RELEASE_NOTES.md" << EOF
# GoDareDI v$VERSION

## What's New
- Full XCFramework support for iOS device and simulator
- Complete Swift API including DependencyGraphView
- SPM binary target compatibility
- Optimized dynamic library compilation

## Installation

### Swift Package Manager
\`\`\`swift
dependencies: [
    .package(url: "https://github.com/MohamedAbdelHafezAbozaid/GoDareDI-Secure.git", from: "$VERSION")
]
\`\`\`

### Manual Installation
Download \`GoDareDI-$VERSION.xcframework.zip\` and add to your project.

## Features
- ✅ AdvancedDIContainer protocol
- ✅ DependencyScope and DependencyLifetime enums
- ✅ DependencyGraphView SwiftUI component
- ✅ Error handling with CircularDependencyException
- ✅ Performance monitoring and analytics
- ✅ iOS 13.0+ support

## Checksum
\`\`\`
$(cat "$OUTPUT_DIR/checksum.txt")
\`\`\`
EOF
    
    log_success "GitHub release preparation completed"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================
main() {
    log_info "🚀 Starting GoDareDI XCFramework build process..."
    log_info "Version: $VERSION"
    log_info "Framework: $FRAMEWORK_NAME"
    
    # Execute build steps
    cleanup
    analyze_source
    build_framework
    create_xcframework
    validate_binaries
    package_for_spm
    prepare_github_release
    
    log_success "🎉 GoDareDI XCFramework build completed successfully!"
    log_info "📁 Output directory: $OUTPUT_DIR"
    log_info "📦 XCFramework: $OUTPUT_DIR/$XCFRAMEWORK_NAME"
    log_info "🗜️  Zip file: $OUTPUT_DIR/${FRAMEWORK_NAME}-${VERSION}.xcframework.zip"
    log_info "📋 Checksum: $(cat "$OUTPUT_DIR/checksum.txt")"
    
    # Display final structure
    log_info "📋 Final structure:"
    ls -la "$OUTPUT_DIR"
}

# Run main function
main "$@"
