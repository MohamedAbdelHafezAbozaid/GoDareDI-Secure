#!/bin/bash

# Fix XCFramework binaries by converting object files to static libraries

echo "🔧 Fixing XCFramework binaries..."

XCFRAMEWORK_PATH="GoDareDI-XCFramework.xcframework"

if [ ! -d "$XCFRAMEWORK_PATH" ]; then
    echo "❌ XCFramework not found at $XCFRAMEWORK_PATH"
    exit 1
fi

# Function to fix framework binary
fix_framework_binary() {
    local framework_path="$1"
    local platform="$2"
    
    echo "🔨 Fixing binary for $platform..."
    
    local binary_path="$framework_path/GoDareDI"
    
    if [ -f "$binary_path" ]; then
        # Check if it's an object file
        if file "$binary_path" | grep -q "object"; then
            echo "📦 Converting object file to static library for $platform..."
            
            # Create a temporary static library
            local temp_lib="/tmp/godare_${platform}.a"
            ar rcs "$temp_lib" "$binary_path"
            
            # Replace the original with the static library
            mv "$temp_lib" "$binary_path"
            
            echo "✅ Fixed binary for $platform"
        else
            echo "✅ Binary for $platform is already correct"
        fi
    else
        echo "❌ Binary not found for $platform"
    fi
}

# Fix each platform
fix_framework_binary "$XCFRAMEWORK_PATH/ios-arm64/GoDareDI.framework" "ios-arm64"
fix_framework_binary "$XCFRAMEWORK_PATH/ios-arm64-simulator/GoDareDI.framework" "ios-arm64-simulator"
fix_framework_binary "$XCFRAMEWORK_PATH/ios-x86_64-simulator/GoDareDI.framework" "ios-x86_64-simulator"

echo "✅ XCFramework binaries fixed!"
echo "📦 Ready for distribution!"
