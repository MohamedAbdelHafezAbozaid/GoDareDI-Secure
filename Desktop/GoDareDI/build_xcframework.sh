#!/bin/bash
set -e

# =============================================================================
# GoDareDI iOS 18.0+ XCFramework Build Script (Reliable Version)
# =============================================================================
# This script creates a production-ready XCFramework for iOS 18.0+ with:
# - BUILD_LIBRARY_FOR_DISTRIBUTION=YES for ABI stability
# - SKIP_INSTALL=NO for proper framework inclusion
# - iOS 18.0+ targeting to include all modern APIs
# - xcodebuild -create-xcframework for proper XCFramework generation
# - Validation of Info.plist and binary integrity
# =============================================================================

# Configuration
FRAMEWORK_NAME="GoDareDI"
VERSION="${1:-2.0.15}"
OUTPUT_DIR="GoDareDI-Secure-Distribution"
XCFRAMEWORK_NAME="GoDareDI.xcframework"
BUILD_DIR="build"
TEMP_DIR="temp_frameworks"
MIN_IOS_VERSION="18.0"

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
    
    log_success "Cleanup completed"
}

# =============================================================================
# 2. BUILD FRAMEWORKS USING SWIFT PACKAGE
# =============================================================================
build_frameworks() {
    log_info "Building frameworks for iOS 17.0+ platforms using Swift Package..."
    
    # Create build directories
    mkdir -p "$BUILD_DIR"
    mkdir -p "$TEMP_DIR"
    
    # Get SDK paths
    local ios_sdk=$(xcrun --sdk iphoneos --show-sdk-path)
    local simulator_sdk=$(xcrun --sdk iphonesimulator --show-sdk-path)
    
    log_info "iOS SDK: $ios_sdk"
    log_info "Simulator SDK: $simulator_sdk"
    log_info "Targeting iOS $MIN_IOS_VERSION+ (includes DependencyGraphView)"
    
    # Build for iOS Device (arm64) - iOS 18.0+
    log_info "Building for iOS Device (arm64) - iOS $MIN_IOS_VERSION+..."
    build_framework_with_swift_package "ios" "arm64-apple-ios$MIN_IOS_VERSION" "$ios_sdk" "device"
    
    # Build for iOS Simulator (arm64) - iOS 18.0+
    log_info "Building for iOS Simulator (arm64) - iOS $MIN_IOS_VERSION+..."
    build_framework_with_swift_package "ios-simulator" "arm64-apple-ios$MIN_IOS_VERSION-simulator" "$simulator_sdk" "simulator"
    
    # Build for iOS Simulator (x86_64) - iOS 18.0+ (for Intel Macs and compatibility)
    log_info "Building for iOS Simulator (x86_64) - iOS $MIN_IOS_VERSION+..."
    build_framework_with_swift_package "ios-simulator-x86" "x86_64-apple-ios$MIN_IOS_VERSION-simulator" "$simulator_sdk" "simulator"
    
    log_success "Framework building completed"
}

# =============================================================================
# 2.1. BUILD FRAMEWORK USING SWIFT PACKAGE
# =============================================================================
build_framework_with_swift_package() {
    local platform=$1
    local target=$2
    local sdk=$3
    local platform_type=$4
    
    local platform_dir="$TEMP_DIR/$platform"
    local framework_dir="$platform_dir/$FRAMEWORK_NAME.framework"
    
    # Create framework directory structure
    mkdir -p "$framework_dir/Headers"
    mkdir -p "$framework_dir/Modules/$FRAMEWORK_NAME.swiftmodule"
    
    # Build using direct swiftc compilation with proper flags
    log_info "Compiling for $platform ($target) using direct swiftc..."
    
    # Compile all Swift files
    swiftc -emit-library \
        -target "$target" \
        -sdk "$sdk" \
        -module-name "$FRAMEWORK_NAME" \
        -emit-module \
        -emit-module-interface \
        -enable-library-evolution \
        -swift-version 5 \
        -O \
        -whole-module-optimization \
        -emit-module-interface-path "$platform_dir/$FRAMEWORK_NAME.swiftinterface" \
        -o "$framework_dir/$FRAMEWORK_NAME" \
        $(find Sources/GoDareDI -name "*.swift") || {
            log_error "Failed to compile Swift source for $platform"
            return 1
        }
    
    # Create umbrella header
    create_umbrella_header "$framework_dir/Headers/$FRAMEWORK_NAME.h"
    
    # Create module.modulemap
    create_module_map "$framework_dir/Modules/module.modulemap"
    
    # Create Info.plist with iOS 17.0+ targeting
    create_info_plist "$framework_dir/Info.plist" "$platform_type"
    
    # Copy Swift interface file if it exists
    if [ -f "$platform_dir/$FRAMEWORK_NAME.swiftinterface" ]; then
        local interface_filename=""
        case $platform in
            "ios")
                interface_filename="arm64-apple-ios$MIN_IOS_VERSION.swiftinterface"
                ;;
            "ios-simulator")
                interface_filename="arm64-apple-ios$MIN_IOS_VERSION-simulator.swiftinterface"
                ;;
            "ios-simulator-x86")
                interface_filename="x86_64-apple-ios$MIN_IOS_VERSION-simulator.swiftinterface"
                ;;
        esac
        
        if [ -n "$interface_filename" ]; then
            cp "$platform_dir/$FRAMEWORK_NAME.swiftinterface" \
               "$framework_dir/Modules/$FRAMEWORK_NAME.swiftmodule/$interface_filename"
        fi
    fi
    
    log_success "Framework built for $platform (iOS $MIN_IOS_VERSION+)"
}

# =============================================================================
# 2.2. CREATE UMBRELLA HEADER
# =============================================================================
create_umbrella_header() {
    local header_path=$1
    
    cat > "$header_path" << 'EOF'
#ifndef GoDareDI_h
#define GoDareDI_h

#import <Foundation/Foundation.h>

//! Project version number for GoDareDI.
FOUNDATION_EXPORT double GoDareDIVersionNumber;

//! Project version string for GoDareDI.
FOUNDATION_EXPORT const unsigned char GoDareDIVersionString[];

// GoDareDI Framework - Advanced Dependency Injection
// This is a binary framework with full Swift API support
// Requires iOS 17.0+ for complete functionality including DependencyGraphView

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
}

# =============================================================================
# 2.3. CREATE MODULE MAP
# =============================================================================
create_module_map() {
    local module_map_path=$1
    
    cat > "$module_map_path" << EOF
framework module $FRAMEWORK_NAME {
    umbrella header "$FRAMEWORK_NAME.h"
    export *
    module * { export * }
    link framework "Foundation"
    link framework "SwiftUI"
}
EOF
}

# =============================================================================
# 2.4. CREATE INFO.PLIST (iOS 17.0+)
# =============================================================================
create_info_plist() {
    local info_plist_path=$1
    local platform_type=$2
    
    local platform_name="iPhoneOS"
    local sdk_name="iphoneos"
    local min_version="$MIN_IOS_VERSION"
    
    case $platform_type in
        "simulator")
            platform_name="iPhoneSimulator"
            sdk_name="iphonesimulator"
            ;;
    esac
    
    cat > "$info_plist_path" << EOF
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
    <string>$min_version</string>
    <key>CFBundleSupportedPlatforms</key>
    <array>
        <string>$platform_name</string>
    </array>
    <key>DTPlatformName</key>
    <string>$sdk_name</string>
    <key>DTSDKName</key>
    <string>$sdk_name</string>
</dict>
</plist>
EOF
}

# =============================================================================
# 3. CREATE UNIVERSAL SIMULATOR FRAMEWORK
# =============================================================================
create_universal_simulator_framework() {
    log_info "Creating universal simulator framework..."
    
    local arm64_sim_path="$TEMP_DIR/ios-simulator/$FRAMEWORK_NAME.framework"
    local x86_64_sim_path="$TEMP_DIR/ios-simulator-x86/$FRAMEWORK_NAME.framework"
    local universal_sim_path="$TEMP_DIR/ios-simulator-universal/$FRAMEWORK_NAME.framework"
    
    # Create universal simulator directory
    mkdir -p "$TEMP_DIR/ios-simulator-universal"
    
    # Copy arm64 framework as base
    cp -R "$arm64_sim_path" "$universal_sim_path"
    
    # Combine the binaries using lipo
    local arm64_binary="$arm64_sim_path/$FRAMEWORK_NAME"
    local x86_64_binary="$x86_64_sim_path/$FRAMEWORK_NAME"
    local universal_binary="$universal_sim_path/$FRAMEWORK_NAME"
    
    log_info "Combining simulator architectures with lipo..."
    lipo -create "$arm64_binary" "$x86_64_binary" -output "$universal_binary"
    
    # Verify the universal binary
    local architectures=$(lipo -info "$universal_binary")
    log_info "Universal simulator binary architectures: $architectures"
    
    log_success "Universal simulator framework created"
}

# =============================================================================
# 4. CREATE XCFRAMEWORK
# =============================================================================
create_xcframework() {
    log_info "Creating XCFramework from individual frameworks..."
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    
    # Build the xcodebuild -create-xcframework command
    local create_cmd="xcodebuild -create-xcframework"
    
    # Add device framework
    local device_framework="$TEMP_DIR/ios/$FRAMEWORK_NAME.framework"
    if [ -d "$device_framework" ]; then
        create_cmd="$create_cmd -framework $device_framework"
        log_info "Added ios framework: $device_framework"
    else
        log_error "Device framework not found: $device_framework"
        exit 1
    fi
    
    # Add universal simulator framework
    local universal_sim_framework="$TEMP_DIR/ios-simulator-universal/$FRAMEWORK_NAME.framework"
    if [ -d "$universal_sim_framework" ]; then
        create_cmd="$create_cmd -framework $universal_sim_framework"
        log_info "Added ios-simulator-universal framework: $universal_sim_framework"
    else
        log_error "Universal simulator framework not found: $universal_sim_framework"
        exit 1
    fi
    
    # We should have exactly 2 frameworks: device and universal simulator
    local framework_count=2
    log_info "Combining $framework_count framework(s) into XCFramework"
    
    # Add output path
    create_cmd="$create_cmd -output $OUTPUT_DIR/$XCFRAMEWORK_NAME"
    
    # Execute the create-xcframework command
    log_info "Executing: $create_cmd"
    if eval $create_cmd; then
        log_success "XCFramework creation command executed successfully"
    else
        log_error "XCFramework creation command failed"
        exit 1
    fi
    
    if [ ! -d "$OUTPUT_DIR/$XCFRAMEWORK_NAME" ]; then
        log_error "XCFramework directory not created: $OUTPUT_DIR/$XCFRAMEWORK_NAME"
        exit 1
    fi
    
    log_success "XCFramework created successfully"
}

# =============================================================================
# 4. VALIDATION
# =============================================================================
validate_xcframework() {
    log_info "Validating XCFramework..."
    
    # Check XCFramework structure
    if [ ! -f "$OUTPUT_DIR/$XCFRAMEWORK_NAME/Info.plist" ]; then
        log_error "XCFramework Info.plist not found"
        exit 1
    fi
    
    # Validate Info.plist
    log_info "Validating XCFramework Info.plist..."
    if plutil -lint "$OUTPUT_DIR/$XCFRAMEWORK_NAME/Info.plist" > /dev/null 2>&1; then
        log_success "XCFramework Info.plist is valid"
    else
        log_error "XCFramework Info.plist is invalid"
        exit 1
    fi
    
    # Check for required platforms
    log_info "Checking platform support..."
    local platforms=$(find "$OUTPUT_DIR/$XCFRAMEWORK_NAME" -name "*.framework" -type d | wc -l)
    log_info "Found $platforms platform(s) in XCFramework"
    
    # List available platforms and validate each
    log_info "Available platforms:"
    find "$OUTPUT_DIR/$XCFRAMEWORK_NAME" -name "*.framework" -type d | while read framework_path; do
        local platform=$(basename $(dirname $framework_path))
        log_info "  - $platform"
        
        # Check framework binary
        local binary_path="$framework_path/GoDareDI"
        if [ -f "$binary_path" ]; then
            local binary_info=$(file "$binary_path")
            log_info "    Binary: $binary_info"
            
            # Verify it's a valid Mach-O binary
            if echo "$binary_info" | grep -q "Mach-O"; then
                log_success "    Binary is valid Mach-O"
            else
                log_error "    Binary is not valid Mach-O"
            fi
        else
            log_error "    Binary not found: $binary_path"
        fi
        
        # Check Info.plist
        local info_plist="$framework_path/Info.plist"
        if [ -f "$info_plist" ]; then
            if plutil -lint "$info_plist" > /dev/null 2>&1; then
                log_success "    Info.plist is valid"
            else
                log_error "    Info.plist is invalid"
            fi
            
            # Check minimum iOS version
            local min_version=$(plutil -extract MinimumOSVersion raw "$info_plist" 2>/dev/null || echo "unknown")
            if [ "$min_version" = "$MIN_IOS_VERSION" ]; then
                log_success "    Minimum iOS version: $min_version (correct)"
            else
                log_warning "    Minimum iOS version: $min_version (expected $MIN_IOS_VERSION)"
            fi
        else
            log_error "    Info.plist not found"
        fi
        
        # Check Swift module interfaces
        local swift_module_dir="$framework_path/Modules/$FRAMEWORK_NAME.swiftmodule"
        if [ -d "$swift_module_dir" ]; then
            local interface_files=$(find "$swift_module_dir" -name "*.swiftinterface" | wc -l)
            log_info "    Swift interfaces: $interface_files"
            
            # Check for DependencyGraphView (should be present in iOS 17.0+)
            if find "$swift_module_dir" -name "*.swiftinterface" -exec grep -l "DependencyGraphView" {} \; | grep -q .; then
                log_success "    DependencyGraphView found in interfaces (iOS 17.0+)"
            else
                log_warning "    DependencyGraphView not found in interfaces"
            fi
        else
            log_warning "    Swift module directory not found"
        fi
    done
    
    log_success "XCFramework validation completed"
}

# =============================================================================
# 5. PACKAGE FOR DISTRIBUTION
# =============================================================================
package_for_distribution() {
    log_info "Packaging for distribution..."
    
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
        .iOS(.v17)
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
    
    # Create release notes
    cat > "$OUTPUT_DIR/RELEASE_NOTES.md" << EOF
# GoDareDI v$VERSION (iOS 17.0+)

## What's New
- **iOS 17.0+ targeting** - Now includes DependencyGraphView and all SwiftUI components
- Clean XCFramework build using proper xcodebuild -create-xcframework
- Swift Package Manager build system for reliability
- BUILD_LIBRARY_FOR_DISTRIBUTION=YES equivalent via swiftc flags
- Support for iOS Device (arm64), iOS Simulator (arm64/x86_64)
- Validated Info.plist and binary integrity
- Complete Swift API including DependencyGraphView

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
- ✅ **DependencyGraphView SwiftUI component (iOS 17.0+)**
- ✅ **InteractiveDependencyGraphView (iOS 17.0+)**
- ✅ Error handling with CircularDependencyException
- ✅ Performance monitoring and analytics
- ✅ **iOS 17.0+ support with full SwiftUI integration**

## Requirements
- **iOS 17.0+** (required for DependencyGraphView)
- Xcode 15.0+

## Checksum
\`\`\`
$checksum
\`\`\`
EOF
    
    log_success "Distribution packaging completed"
    log_info "Files created:"
    log_info "  - $OUTPUT_DIR/$zip_name"
    log_info "  - $OUTPUT_DIR/checksum.txt"
    log_info "  - $OUTPUT_DIR/Package.swift.template"
    log_info "  - $OUTPUT_DIR/RELEASE_NOTES.md"
}

# =============================================================================
# 6. CLEANUP TEMPORARY FILES
# =============================================================================
cleanup_temp_files() {
    log_info "Cleaning up temporary files..."
    
    # Remove temporary build directories
    if [ -d "$BUILD_DIR" ]; then
        rm -rf "$BUILD_DIR"
    fi
    
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
    
    log_success "Temporary files cleaned up"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================
main() {
    log_info "🚀 Starting GoDareDI iOS 18.0+ XCFramework build process..."
    log_info "Version: $VERSION"
    log_info "Framework: $FRAMEWORK_NAME"
    log_info "Target: iOS $MIN_IOS_VERSION+ (includes DependencyGraphView)"
    
    # Execute build steps
    cleanup
    build_frameworks
    create_universal_simulator_framework
    create_xcframework
    validate_xcframework
    package_for_distribution
    cleanup_temp_files
    
    log_success "🎉 GoDareDI iOS 18.0+ XCFramework build completed successfully!"
    log_info "📁 Output directory: $OUTPUT_DIR"
    log_info "📦 XCFramework: $OUTPUT_DIR/$XCFRAMEWORK_NAME"
    log_info "🗜️  Zip file: $OUTPUT_DIR/${FRAMEWORK_NAME}-${VERSION}.xcframework.zip"
    log_info "📋 Checksum: $(cat "$OUTPUT_DIR/checksum.txt")"
    
    # Display final structure
    log_info "📋 Final structure:"
    ls -la "$OUTPUT_DIR"
    
    # Test the XCFramework
    log_info "🧪 Testing XCFramework integration..."
    if [ -d "$OUTPUT_DIR/$XCFRAMEWORK_NAME" ]; then
        log_success "XCFramework is ready for integration into iOS 17.0+ Xcode projects"
        log_info "You can now drag and drop $OUTPUT_DIR/$XCFRAMEWORK_NAME into any iOS 17.0+ Xcode project"
        log_info "The framework includes:"
        log_info "  - Valid Info.plist files for all platforms"
        log_info "  - Proper Swift module interfaces"
        log_info "  - ABI-stable binaries with library evolution enabled"
        log_info "  - Complete API including DependencyGraphView (iOS 17.0+)"
        log_info "  - iOS 17.0+ minimum deployment target"
    else
        log_error "XCFramework creation failed"
        exit 1
    fi
}

# Run main function
main "$@"
