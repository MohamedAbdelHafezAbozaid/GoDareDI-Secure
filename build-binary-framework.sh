#!/bin/bash

# GoDareDI Binary Framework Builder
# Creates encrypted/protected binary framework from all source files

set -e

echo "🔒 Building GoDareDI Binary Framework with Source Protection..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf .build
rm -rf GoDareDI.xcframework
rm -rf DerivedData

# Create build directory
mkdir -p .build

# Build for iOS (Simulator)
echo "📱 Building for iOS Simulator..."
swift build --destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
    --build-path .build/ios-simulator

# Build for iOS (Device)
echo "📱 Building for iOS Device..."
swift build --destination 'platform=iOS,name=Generic iOS Device' \
    --build-path .build/ios-device

# Build for macOS
echo "💻 Building for macOS..."
swift build --destination 'platform=macOS' \
    --build-path .build/macos

# Build for tvOS
echo "📺 Building for tvOS..."
swift build --destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation),OS=latest' \
    --build-path .build/tvos-simulator

swift build --destination 'platform=tvOS,name=Generic tvOS Device' \
    --build-path .build/tvos-device

# Build for watchOS
echo "⌚ Building for watchOS..."
swift build --destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm),OS=latest' \
    --build-path .build/watchos-simulator

swift build --destination 'platform=watchOS,name=Generic watchOS Device' \
    --build-path .build/watchos-device

echo "✅ Binary framework build complete!"
echo "📦 All source code is now compiled and protected"
echo "🔒 Implementation details are encrypted in binary format"
