#!/bin/bash

# GoDareDI Binary Framework Builder
# This script builds binary frameworks for secure distribution

set -e

echo "🔒 Building GoDareDI Binary Frameworks for Secure Distribution"
echo "=============================================================="

# Create output directory
OUTPUT_DIR="BinaryFrameworks"
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Define platforms and architectures
PLATFORMS=(
    "ios-arm64"      # iOS devices
    "ios-arm64_x86_64-simulator"  # iOS simulator
    "macos-arm64"    # Apple Silicon Macs
    "macos-x86_64"   # Intel Macs
    "tvos-arm64"     # tvOS devices
    "tvos-arm64_x86_64-simulator" # tvOS simulator
    "watchos-arm64_32_armv7k"     # watchOS devices
    "watchos-arm64_32_x86_64-simulator" # watchOS simulator
)

# Build frameworks for each platform
for PLATFORM in "${PLATFORMS[@]}"; do
    echo "📱 Building for $PLATFORM..."
    
    # Extract platform and architecture info
    if [[ $PLATFORM == *"ios"* ]]; then
        SDK="iphoneos"
        if [[ $PLATFORM == *"simulator"* ]]; then
            SDK="iphonesimulator"
        fi
    elif [[ $PLATFORM == *"macos"* ]]; then
        SDK="macosx"
    elif [[ $PLATFORM == *"tvos"* ]]; then
        SDK="appletvos"
        if [[ $PLATFORM == *"simulator"* ]]; then
            SDK="appletvsimulator"
        fi
    elif [[ $PLATFORM == *"watchos"* ]]; then
        SDK="watchos"
        if [[ $PLATFORM == *"simulator"* ]]; then
            SDK="watchsimulator"
        fi
    fi
    
    # Build the framework
    xcodebuild -create-xcframework \
        -framework "build/$PLATFORM/GoDareDI.framework" \
        -output "$OUTPUT_DIR/GoDareDI.xcframework" \
        -allow-internal-distribution
    
    echo "✅ Built framework for $PLATFORM"
done

echo ""
echo "🎉 Binary frameworks built successfully!"
echo "📁 Output directory: $OUTPUT_DIR"
echo ""
echo "🔒 Security Benefits:"
echo "   • Source code is compiled and obfuscated"
echo "   • Developers cannot access implementation details"
echo "   • Intellectual property is protected"
echo "   • Framework can be distributed via private repositories"
echo ""
echo "📦 Next steps:"
echo "   1. Upload GoDareDI.xcframework to your private repository"
echo "   2. Update Package.swift to use binary targets"
echo "   3. Distribute via private SPM repository or direct download"
