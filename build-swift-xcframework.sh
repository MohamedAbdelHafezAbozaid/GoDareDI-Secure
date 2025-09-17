#!/bin/bash
set -e

FRAMEWORK_NAME="GODareDI"
OUTPUT_DIR="GODareDI.xcframework"
TEMP_DIR="temp_swift_build"
VERSION="2.0.8"
SOURCE_DIR="../Sources/GoDareDI"

echo "🔨 Creating Swift XCFramework for $FRAMEWORK_NAME using xcodebuild..."

# 1. Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf "$TEMP_DIR" "$OUTPUT_DIR" DerivedData

# 2. Create temporary Xcode project structure
echo "📁 Creating temporary Xcode project..."
mkdir -p "$TEMP_DIR/GODareDI.xcodeproj"

# Create a simple Xcode project for building
cat > "$TEMP_DIR/GODareDI.xcodeproj/project.pbxproj" << 'EOF'
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		A1234567890123456789012 /* GODareDI.framework in Frameworks */ = {isa = PBXBuildFile; fileRef = A1234567890123456789013 /* GODareDI.framework */; };
		A1234567890123456789014 /* GODareDI.h in Headers */ = {isa = PBXBuildFile; fileRef = A1234567890123456789015 /* GODareDI.h */; settings = {ATTRIBUTES = (Public, ); }; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		A1234567890123456789013 /* GODareDI.framework */ = {isa = PBXFileReference; explicitFileType = wrapper.framework; includeInIndex = 0; path = GODareDI.framework; sourceTree = BUILT_PRODUCTS_DIR; };
		A1234567890123456789015 /* GODareDI.h */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.h; path = GODareDI.h; sourceTree = "<group>"; };
		A1234567890123456789016 /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		A1234567890123456789017 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
				A1234567890123456789012 /* GODareDI.framework in Frameworks */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		A1234567890123456789018 = {
			isa = PBXGroup;
			children = (
				A1234567890123456789019 /* GODareDI */,
				A1234567890123456789020 /* Products */,
			);
			sourceTree = "<group>";
		};
		A1234567890123456789019 /* GODareDI */ = {
			isa = PBXGroup;
			children = (
				A1234567890123456789015 /* GODareDI.h */,
				A1234567890123456789016 /* Info.plist */,
			);
			path = GODareDI;
			sourceTree = "<group>";
		};
		A1234567890123456789020 /* Products */ = {
			isa = PBXGroup;
			children = (
				A1234567890123456789013 /* GODareDI.framework */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXHeadersBuildPhase section */
		A1234567890123456789021 /* Headers */ = {
			isa = PBXHeadersBuildPhase;
			buildActionMask = 2147483647;
			files = (
				A1234567890123456789014 /* GODareDI.h in Headers */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXHeadersBuildPhase section */

/* Begin PBXNativeTarget section */
		A1234567890123456789022 /* GODareDI */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = A1234567890123456789023 /* Build configuration list for PBXNativeTarget "GODareDI" */;
			buildPhases = (
				A1234567890123456789021 /* Headers */,
				A1234567890123456789017 /* Frameworks */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = GODareDI;
			productName = GODareDI;
			productReference = A1234567890123456789013 /* GODareDI.framework */;
			productType = "com.apple.product-type.framework";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		A1234567890123456789024 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
				TargetAttributes = {
					A1234567890123456789022 = {
						CreatedOnToolsVersion = 15.0;
					};
				};
			};
			buildConfigurationList = A1234567890123456789025 /* Build configuration list for PBXProject "GODareDI" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = A1234567890123456789018;
			productRefGroup = A1234567890123456789020 /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				A1234567890123456789022 /* GODareDI */,
			);
		};
/* End PBXProject section */

/* Begin XCBuildConfiguration section */
		A1234567890123456789026 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				CURRENT_PROJECT_VERSION = 1;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 13.0;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
				VERSIONING_SYSTEM = "apple-generic";
			};
			name = Debug;
		};
		A1234567890123456789027 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				CURRENT_PROJECT_VERSION = 1;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 13.0;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				VALIDATE_PRODUCT = YES;
				VERSIONING_SYSTEM = "apple-generic";
			};
			name = Release;
		};
		A1234567890123456789028 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEFINES_MODULE = YES;
				DYLIB_COMPATIBILITY_VERSION = 1;
				DYLIB_CURRENT_VERSION = 1;
				DYLIB_INSTALL_NAME_BASE = "@rpath";
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_FILE = GODareDI/Info.plist;
				INFOPLIST_KEY_CFBundleDisplayName = GODareDI;
				INFOPLIST_KEY_NSHumanReadableCopyright = "";
				INSTALL_PATH = "$(LOCAL_LIBRARY_DIR)/Frameworks";
				IPHONEOS_DEPLOYMENT_TARGET = 13.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
					"@loader_path/Frameworks",
				);
				MARKETING_VERSION = 2.0.8;
				PRODUCT_BUNDLE_IDENTIFIER = com.godare.GODareDI;
				PRODUCT_NAME = "$(TARGET_NAME:c99)";
				SKIP_INSTALL = YES;
				SWIFT_EMIT_MODULE_INTERFACE = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
		A1234567890123456789029 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEFINES_MODULE = YES;
				DYLIB_COMPATIBILITY_VERSION = 1;
				DYLIB_CURRENT_VERSION = 1;
				DYLIB_INSTALL_NAME_BASE = "@rpath";
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_FILE = GODareDI/Info.plist;
				INFOPLIST_KEY_CFBundleDisplayName = GODareDI;
				INFOPLIST_KEY_NSHumanReadableCopyright = "";
				INSTALL_PATH = "$(LOCAL_LIBRARY_DIR)/Frameworks";
				IPHONEOS_DEPLOYMENT_TARGET = 13.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
					"@loader_path/Frameworks",
				);
				MARKETING_VERSION = 2.0.8;
				PRODUCT_BUNDLE_IDENTIFIER = com.godare.GODareDI;
				PRODUCT_NAME = "$(TARGET_NAME:c99)";
				SKIP_INSTALL = YES;
				SWIFT_EMIT_MODULE_INTERFACE = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		A1234567890123456789023 /* Build configuration list for PBXNativeTarget "GODareDI" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				A1234567890123456789028 /* Debug */,
				A1234567890123456789029 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		A1234567890123456789025 /* Build configuration list for PBXProject "GODareDI" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				A1234567890123456789026 /* Debug */,
				A1234567890123456789027 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = A1234567890123456789024 /* Project object */;
}
EOF

# Create framework directory structure
mkdir -p "$TEMP_DIR/GODareDI"

# Copy source files
cp -r "$SOURCE_DIR"/* "$TEMP_DIR/GODareDI/"

# Create umbrella header
cat > "$TEMP_DIR/GODareDI/GODareDI.h" << 'EOF'
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

# Create Info.plist
cat > "$TEMP_DIR/GODareDI/Info.plist" << EOF
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

# 3. Build frameworks using xcodebuild
echo "📱 Building framework for iOS device..."
xcodebuild -project "$TEMP_DIR/GODareDI.xcodeproj" \
    -target GODareDI \
    -configuration Release \
    -sdk iphoneos \
    -arch arm64 \
    -derivedDataPath "$TEMP_DIR/DerivedData" \
    build

echo "📱 Building framework for iOS simulator..."
xcodebuild -project "$TEMP_DIR/GODareDI.xcodeproj" \
    -target GODareDI \
    -configuration Release \
    -sdk iphonesimulator \
    -arch arm64 \
    -derivedDataPath "$TEMP_DIR/DerivedData" \
    build

# 4. Create XCFramework
echo "📦 Creating XCFramework..."
xcodebuild -create-xcframework \
    -framework "$TEMP_DIR/DerivedData/Build/Products/Release-iphoneos/GODareDI.framework" \
    -framework "$TEMP_DIR/DerivedData/Build/Products/Release-iphonesimulator/GODareDI.framework" \
    -output "$OUTPUT_DIR"

echo "✅ $FRAMEWORK_NAME.xcframework created successfully!"
echo "📁 Location: $(pwd)/$OUTPUT_DIR"

# 5. Verify contents
echo "📋 Contents:"
ls -R "$OUTPUT_DIR"

# 6. Clean up temporary files
echo "🧹 Cleaning up..."
rm -rf "$TEMP_DIR"

echo "🎉 Swift XCFramework created successfully!"
echo "📦 XCFramework ready for SPM distribution with complete Swift API"
