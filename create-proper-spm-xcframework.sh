#!/bin/bash

set -e

echo "🔨 Creating SPM-compatible GODareDI XCFramework using xcodebuild..."

FRAMEWORK_NAME="GODareDI"
VERSION="2.0.6"
OUTPUT_DIR="${FRAMEWORK_NAME}.xcframework"
TEMP_DIR="temp_xcodebuild"

# Clean and recreate directories
echo "🧹 Cleaning previous builds..."
rm -rf "$OUTPUT_DIR"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# Create a temporary Swift package
echo "📦 Creating temporary Swift package..."
mkdir -p "$TEMP_DIR/Sources/$FRAMEWORK_NAME"
mkdir -p "$TEMP_DIR/Tests/${FRAMEWORK_NAME}Tests"

# Create a minimal Swift source file
cat > "$TEMP_DIR/Sources/$FRAMEWORK_NAME/$FRAMEWORK_NAME.swift" << 'EOF'
import Foundation

// MARK: - Core DI Protocol
@available(iOS 13.0, *)
public protocol AdvancedDIContainer: Sendable {
    func register<T: Sendable>(_ type: T.Type, scope: DependencyScope, lifetime: DependencyLifetime, factory: @escaping @Sendable (AdvancedDIContainer) async throws -> T)
    func register<T: Sendable>(_ type: T.Type, scope: DependencyScope, factory: @escaping @Sendable (AdvancedDIContainer) async throws -> T)
    func registerSync<T: Sendable>(_ type: T.Type, scope: DependencyScope, lifetime: DependencyLifetime, factory: @escaping @Sendable (AdvancedDIContainer) throws -> T)
    func registerSync<T: Sendable>(_ type: T.Type, scope: DependencyScope, factory: @escaping @Sendable (AdvancedDIContainer) throws -> T)
    func resolve<T: Sendable>() async throws -> T
    func resolve<T: Sendable>(_ type: T.Type) async throws -> T
    func resolveSync<T: Sendable>() throws -> T
    func resolveSync<T: Sendable>(_ type: T.Type) throws -> T
    func createScope(_ scopeId: String) async
    func disposeScope(_ scopeId: String) async
    func setCurrentScope(_ scopeId: String) async
    func getCurrentScope() -> String
    func validateDependencies() async throws
    func getDependencyGraph() async -> DependencyGraph
    func analyzeDependencyGraph() async -> GraphAnalysis
    func analyzeDependencyGraphWithMetrics() async -> GraphAnalysis
    func isRegistered<T>(_ type: T.Type) -> Bool
    func getPerformanceMetrics() async -> PerformanceMetrics
    func preloadDependencies() async
    func cleanup() async
    func preloadAllGeneric() async throws
    func preloadSmart() async throws
    func preloadViewModelsOnly() async throws
    func getMetadata<T>(_ type: T.Type) -> DependencyMetadata?
    func registerWithMetadata<T>(_ type: T.Type, metadata: DependencyMetadata)
    func getMetadata(for key: String) -> DependencyMetadata?
    func getDependencyMap() -> [String: Set<String>]
    func getRegisteredServicesCount() -> Int
    func debugPrintMetadata()
    func debugPrintFactories()
}

// MARK: - Dependency Scope
@available(iOS 13.0, *)
public enum DependencyScope: String, CaseIterable, Codable, Sendable {
    case singleton = "singleton"
    case scoped = "scoped"
    case transient = "transient"
    case lazy = "lazy"
}

// MARK: - Dependency Lifetime
@available(iOS 13.0, *)
public enum DependencyLifetime: String, Hashable, CaseIterable, Codable, Sendable {
    case application = "application"
    case session = "session"
    case request = "request"
    case custom = "custom"
}

// MARK: - Dependency Metadata
@available(iOS 13.0, *)
public struct DependencyMetadata: Codable, Sendable {
    public let type: String
    public let scope: DependencyScope
    public let lifetime: DependencyLifetime
    let lazy: Bool
    let dependencies: [String]
    let registrationTime: Date
    let lastAccessed: Date?
    
    public init(type: Any.Type, scope: DependencyScope, lifetime: DependencyLifetime, lazy: Bool = false, dependencies: [String] = []) {
        self.type = String(describing: type)
        self.scope = scope
        self.lifetime = lifetime
        self.lazy = lazy
        self.dependencies = dependencies
        self.registrationTime = Date()
        self.lastAccessed = nil
    }
    
    mutating func updateLastAccessed() {
        // This would update the lastAccessed time
    }
}

// MARK: - Performance Metrics
@available(iOS 13.0, *)
public struct PerformanceMetrics: Codable, Sendable {
    public let averageResolutionTime: TimeInterval
    public let cacheHitRate: Double
    public let memoryUsage: Double
    public let totalResolutions: Int
    public let circularDependencyCount: Int
    
    public init(averageResolutionTime: TimeInterval, cacheHitRate: Double, memoryUsage: Double, totalResolutions: Int, circularDependencyCount: Int) {
        self.averageResolutionTime = averageResolutionTime
        self.cacheHitRate = cacheHitRate
        self.memoryUsage = memoryUsage
        self.totalResolutions = totalResolutions
        self.circularDependencyCount = circularDependencyCount
    }
}

// MARK: - Dependency Graph
@available(iOS 13.0, *)
public struct DependencyGraph: Sendable {
    public let nodes: [DependencyNode]
    public let edges: [DependencyEdge]
    public let analysis: GraphAnalysis
    
    public init(nodes: [DependencyNode], edges: [DependencyEdge], analysis: GraphAnalysis) {
        self.nodes = nodes
        self.edges = edges
        self.analysis = analysis
    }
}

// MARK: - Dependency Node
@available(iOS 13.0, *)
public struct DependencyNode: Sendable {
    public let id: String
    public let scope: DependencyScope
    public let dependencies: [String]
    public let layer: Int
    public let isCircular: Bool
    public let position: CGPoint
    public let type: NodeType
    public let category: NodeCategory
    public let complexity: NodeComplexity
    public let performanceMetrics: NodePerformanceMetrics
    public let metadata: [String: String]
    public let tags: [String]
    
    public init(id: String, scope: DependencyScope, dependencies: [String], layer: Int, isCircular: Bool, position: CGPoint, type: NodeType, category: NodeCategory, complexity: NodeComplexity, performanceMetrics: NodePerformanceMetrics, metadata: [String: String], tags: [String]) {
        self.id = id
        self.scope = scope
        self.dependencies = dependencies
        self.layer = layer
        self.isCircular = isCircular
        self.position = position
        self.type = type
        self.category = category
        self.complexity = complexity
        self.performanceMetrics = performanceMetrics
        self.metadata = metadata
        self.tags = tags
    }
}

// MARK: - Dependency Edge
@available(iOS 13.0, *)
public struct DependencyEdge: Sendable {
    public let from: String
    public let to: String
    public let relationship: String
    public let isCircular: Bool
    public let relationshipType: RelationshipType
    public let strength: RelationshipStrength
    public let direction: RelationshipDirection
    public let performanceImpact: PerformanceImpact
    public let metadata: [String: String]
    
    public init(from: String, to: String, relationship: String, isCircular: Bool, relationshipType: RelationshipType, strength: RelationshipStrength, direction: RelationshipDirection, performanceImpact: PerformanceImpact, metadata: [String: String]) {
        self.from = from
        self.to = to
        self.relationship = relationship
        self.isCircular = isCircular
        self.relationshipType = relationshipType
        self.strength = strength
        self.direction = direction
        self.performanceImpact = performanceImpact
        self.metadata = metadata
    }
}

// MARK: - Graph Analysis
@available(iOS 13.0, *)
public struct GraphAnalysis: Sendable {
    public let hasCircularDependencies: Bool
    public let totalNodes: Int
    public let totalDependencies: Int
    public let maxDepth: Int
    public let circularDependencyChains: [[String]]
    public let analysisTime: TimeInterval
    public let memoryUsage: Double
    public let cacheEfficiency: Double
    public let isComplete: Bool
    public let complexityMetrics: ComplexityMetrics
    public let performanceMetrics: GraphPerformanceMetrics
    public let architectureMetrics: ArchitectureMetrics
    public let healthScore: HealthScore
    public let recommendations: [String]
    public let clusters: [[String]]
    public let criticalPaths: [[String]]
    
    public init(hasCircularDependencies: Bool, totalNodes: Int, totalDependencies: Int, maxDepth: Int, circularDependencyChains: [[String]], analysisTime: TimeInterval, memoryUsage: Double, cacheEfficiency: Double, isComplete: Bool, complexityMetrics: ComplexityMetrics, performanceMetrics: GraphPerformanceMetrics, architectureMetrics: ArchitectureMetrics, healthScore: HealthScore, recommendations: [String], clusters: [[String]], criticalPaths: [[String]]) {
        self.hasCircularDependencies = hasCircularDependencies
        self.totalNodes = totalNodes
        self.totalDependencies = totalDependencies
        self.maxDepth = maxDepth
        self.circularDependencyChains = circularDependencyChains
        self.analysisTime = analysisTime
        self.memoryUsage = memoryUsage
        self.cacheEfficiency = cacheEfficiency
        self.isComplete = isComplete
        self.complexityMetrics = complexityMetrics
        self.performanceMetrics = performanceMetrics
        self.architectureMetrics = architectureMetrics
        self.healthScore = healthScore
        self.recommendations = recommendations
        self.clusters = clusters
        self.criticalPaths = criticalPaths
    }
}

// MARK: - Supporting Types
@available(iOS 13.0, *)
public enum NodeType: String, CaseIterable, Codable, Sendable {
    case service = "service"
    case repository = "repository"
    case viewModel = "viewModel"
    case useCase = "useCase"
    case dataSource = "dataSource"
    case network = "network"
    case storage = "storage"
    case analytics = "analytics"
    case other = "other"
}

@available(iOS 13.0, *)
public enum NodeCategory: String, CaseIterable, Codable, Sendable {
    case business = "business"
    case data = "data"
    case presentation = "presentation"
    case infrastructure = "infrastructure"
    case external = "external"
    case other = "other"
}

@available(iOS 13.0, *)
public enum NodeComplexity: String, CaseIterable, Codable, Sendable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
}

@available(iOS 13.0, *)
public struct NodePerformanceMetrics: Codable, Sendable {
    public let resolutionTime: TimeInterval
    public let memoryFootprint: Int
    public let cacheHitRate: Double
    public let resolutionCount: Int
    public let lastResolved: Date
    
    public init(resolutionTime: TimeInterval, memoryFootprint: Int, cacheHitRate: Double, resolutionCount: Int, lastResolved: Date) {
        self.resolutionTime = resolutionTime
        self.memoryFootprint = memoryFootprint
        self.cacheHitRate = cacheHitRate
        self.resolutionCount = resolutionCount
        self.lastResolved = lastResolved
    }
}

@available(iOS 13.0, *)
public enum RelationshipType: String, CaseIterable, Codable, Sendable {
    case dependency = "dependency"
    case composition = "composition"
    case aggregation = "aggregation"
    case inheritance = "inheritance"
    case implementation = "implementation"
    case other = "other"
}

@available(iOS 13.0, *)
public enum RelationshipStrength: String, CaseIterable, Codable, Sendable {
    case weak = "weak"
    case medium = "medium"
    case strong = "strong"
    case critical = "critical"
}

@available(iOS 13.0, *)
public enum RelationshipDirection: String, CaseIterable, Codable, Sendable {
    case unidirectional = "unidirectional"
    case bidirectional = "bidirectional"
    case circular = "circular"
}

@available(iOS 13.0, *)
public enum PerformanceImpact: String, CaseIterable, Codable, Sendable {
    case none = "none"
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
}

@available(iOS 13.0, *)
public struct ComplexityMetrics: Codable, Sendable {
    public let cyclomaticComplexity: Int
    public let cognitiveComplexity: Int
    public let maintainabilityIndex: Int
    
    public init(cyclomaticComplexity: Int, cognitiveComplexity: Int, maintainabilityIndex: Int) {
        self.cyclomaticComplexity = cyclomaticComplexity
        self.cognitiveComplexity = cognitiveComplexity
        self.maintainabilityIndex = maintainabilityIndex
    }
}

@available(iOS 13.0, *)
public struct GraphPerformanceMetrics: Codable, Sendable {
    public let averageResolutionTime: TimeInterval
    public let slowestResolution: TimeInterval
    public let fastestResolution: TimeInterval
    public let totalMemoryFootprint: Int
    public let cacheHitRate: Double
    public let bottleneckNodes: [String]
    public let performanceTrend: String
    
    public init(averageResolutionTime: TimeInterval, slowestResolution: TimeInterval, fastestResolution: TimeInterval, totalMemoryFootprint: Int, cacheHitRate: Double, bottleneckNodes: [String], performanceTrend: String) {
        self.averageResolutionTime = averageResolutionTime
        self.slowestResolution = slowestResolution
        self.fastestResolution = fastestResolution
        self.totalMemoryFootprint = totalMemoryFootprint
        self.cacheHitRate = cacheHitRate
        self.bottleneckNodes = bottleneckNodes
        self.performanceTrend = performanceTrend
    }
}

@available(iOS 13.0, *)
public struct ArchitectureMetrics: Codable, Sendable {
    public let couplingScore: Double
    public let cohesionScore: Double
    public let layeredArchitecture: Bool
    public let dependencyInversion: Bool
    
    public init(couplingScore: Double, cohesionScore: Double, layeredArchitecture: Bool, dependencyInversion: Bool) {
        self.couplingScore = couplingScore
        self.cohesionScore = cohesionScore
        self.layeredArchitecture = layeredArchitecture
        self.dependencyInversion = dependencyInversion
    }
}

@available(iOS 13.0, *)
public struct HealthScore: Codable, Sendable {
    public let overall: Int
    public let performance: Int
    public let maintainability: Int
    public let testability: Int
    public let scalability: Int
    public let security: Int
    public let reliability: Int
    
    public init(overall: Int, performance: Int, maintainability: Int, testability: Int, scalability: Int, security: Int, reliability: Int) {
        self.overall = overall
        self.performance = performance
        self.maintainability = maintainability
        self.testability = testability
        self.scalability = scalability
        self.security = security
        self.reliability = reliability
    }
}

// MARK: - SwiftUI Integration
@available(iOS 17.0, *)
@MainActor
public struct DependencyGraphView {
    let container: AdvancedDIContainer
    
    public init(container: AdvancedDIContainer) {
        self.container = container
    }
    
    public func display() -> String {
        return "Dependency Graph View"
    }
}

// MARK: - Initialization Functions
public func godare_init() {
    print("GODareDI Framework Initialized")
}

public func godare_version() -> Int32 {
    return 206 // Version 2.0.6
}
EOF

# Create Package.swift
cat > "$TEMP_DIR/Package.swift" << EOF
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "$FRAMEWORK_NAME",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "$FRAMEWORK_NAME",
            targets: ["$FRAMEWORK_NAME"]
        ),
    ],
    targets: [
        .target(
            name: "$FRAMEWORK_NAME",
            path: "Sources/$FRAMEWORK_NAME"
        ),
        .testTarget(
            name: "${FRAMEWORK_NAME}Tests",
            dependencies: [.target(name: "$FRAMEWORK_NAME")],
            path: "Tests/${FRAMEWORK_NAME}Tests"
        )
    ]
)
EOF

# Create a test file
cat > "$TEMP_DIR/Tests/${FRAMEWORK_NAME}Tests/${FRAMEWORK_NAME}Tests.swift" << 'EOF'
import XCTest
@testable import GODareDI

final class GODareDITests: XCTestCase {
    func testVersion() throws {
        XCTAssertEqual(godare_version(), 206)
    }
    
    func testInit() throws {
        godare_init()
    }
}
EOF

cd "$TEMP_DIR"

# Build using swift build first to ensure everything compiles
echo "🔨 Building with swift build..."
swift build --configuration release

# Build for iOS device using swift build
echo "📱 Building for iOS device..."
swift build --configuration release \
    -Xswiftc -sdk \
    -Xswiftc "$(xcrun --sdk iphoneos --show-sdk-path)" \
    -Xswiftc -target \
    -Xswiftc arm64-apple-ios13.0

# Build for iOS simulator using swift build
echo "📱 Building for iOS simulator..."
swift build --configuration release \
    -Xswiftc -sdk \
    -Xswiftc "$(xcrun --sdk iphonesimulator --show-sdk-path)" \
    -Xswiftc -target \
    -Xswiftc arm64-apple-ios13.0-simulator

cd ..

# Create XCFramework manually since we're using swift build
echo "📦 Creating XCFramework manually..."

# Create XCFramework structure
mkdir -p "$OUTPUT_DIR/ios-arm64/$FRAMEWORK_NAME.framework"
mkdir -p "$OUTPUT_DIR/ios-arm64-simulator/$FRAMEWORK_NAME.framework"

# Copy the built libraries
cp "$TEMP_DIR/.build/release/lib$FRAMEWORK_NAME.a" "$OUTPUT_DIR/ios-arm64/$FRAMEWORK_NAME.framework/$FRAMEWORK_NAME"
cp "$TEMP_DIR/.build/release/lib$FRAMEWORK_NAME.a" "$OUTPUT_DIR/ios-arm64-simulator/$FRAMEWORK_NAME.framework/$FRAMEWORK_NAME"

# Create framework structure
mkdir -p "$OUTPUT_DIR/ios-arm64/$FRAMEWORK_NAME.framework/Headers"
mkdir -p "$OUTPUT_DIR/ios-arm64/$FRAMEWORK_NAME.framework/Modules"
mkdir -p "$OUTPUT_DIR/ios-arm64-simulator/$FRAMEWORK_NAME.framework/Headers"
mkdir -p "$OUTPUT_DIR/ios-arm64-simulator/$FRAMEWORK_NAME.framework/Modules"

# Create umbrella header
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

# Create Info.plist files
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

# Create XCFramework Info.plist
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

echo "🎉 SPM-compatible XCFramework created successfully!"
echo "📦 XCFramework ready for SPM distribution"
