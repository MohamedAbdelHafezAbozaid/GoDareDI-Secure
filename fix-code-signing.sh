#!/bin/bash

# Fix Code Signing for GoDareDI XCFramework
# This script addresses the "unsigned framework" warning

set -e

echo "🔐 Fixing Code Signing for GoDareDI XCFramework..."

# Check if XCFramework exists
if [ ! -d "GoDareDI.xcframework" ]; then
    echo "❌ GoDareDI.xcframework not found!"
    exit 1
fi

# Step 1: Code sign the existing XCFramework
echo "🔐 Step 1: Code signing the XCFramework..."

# Find all frameworks within the XCFramework
find GoDareDI.xcframework -name "*.framework" -type d | while read framework_path; do
    echo "Signing framework: $framework_path"
    
    # Code sign the framework
    codesign --force --sign - "$framework_path"
    
    # Verify the signature
    codesign --verify --verbose "$framework_path"
done

# Step 2: Code sign the XCFramework itself
echo "🔐 Step 2: Code signing the XCFramework bundle..."
codesign --force --sign - GoDareDI.xcframework

# Step 3: Verify the entire XCFramework
echo "✅ Step 3: Verifying code signing..."
codesign --verify --verbose GoDareDI.xcframework

# Step 4: Display signing information
echo "📋 Step 4: Displaying signing information..."
codesign --display --verbose GoDareDI.xcframework

echo "✅ Code signing completed successfully!"
echo "🔐 The XCFramework is now properly signed"
echo "🎯 Xcode should no longer show the 'unsigned framework' warning"
echo ""
echo "📁 Signed XCFramework: GoDareDI.xcframework"
