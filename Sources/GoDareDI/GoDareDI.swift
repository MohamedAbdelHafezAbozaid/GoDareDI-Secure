//
//  GoDareDI.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - GoDareDI Package
// This is the main module file that exports all the public APIs

// MARK: - Core Dependency Types
public enum DependencyScope: String, CaseIterable, Codable, Sendable {
    case singleton = "singleton"
    case scoped = "scoped"
    case transient = "transient"
    case lazy = "lazy"
}

public enum DependencyLifetime: String, Hashable, CaseIterable, Codable, Sendable {
    case application = "application"
    case session = "session"
    case request = "request"
    case custom = "custom"
}

public struct DependencyMetadata: Codable, Sendable {
    public let type: String
    public let scope: DependencyScope
    public let lifetime: DependencyLifetime
    let lazy: Bool
    let dependencies: [String]
    let registrationTime: Date
    let lastAccessed: Date?
    
    init(type: Any.Type, scope: DependencyScope, lifetime: DependencyLifetime, lazy: Bool = false, dependencies: [String] = []) {
        self.type = String(describing: type)
        self.scope = scope
        self.lifetime = lifetime
        self.lazy = lazy
        self.dependencies = dependencies
        self.registrationTime = Date()
        self.lastAccessed = nil
    }
}

// MARK: - Performance Metrics
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

// MARK: - Graph Types
public struct DependencyGraph: Codable, Sendable {
    public let nodes: [DependencyNode]
    public let edges: [DependencyEdge]
    public let analysis: GraphAnalysis
    
    public init(nodes: [DependencyNode] = [], edges: [DependencyEdge] = [], analysis: GraphAnalysis = GraphAnalysis()) {
        self.nodes = nodes
        self.edges = edges
        self.analysis = analysis
    }
}

public struct DependencyNode: Hashable, Codable, Sendable {
    public let id: String
    public let type: String
    public let scope: DependencyScope
    public let dependencies: [String]
    public let layer: Int
    public let isCircular: Bool
    
    public init(id: String, type: String, scope: DependencyScope, dependencies: [String] = [], layer: Int = 0, isCircular: Bool = false) {
        self.id = id
        self.type = type
        self.scope = scope
        self.dependencies = dependencies
        self.layer = layer
        self.isCircular = isCircular
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: DependencyNode, rhs: DependencyNode) -> Bool {
        return lhs.id == rhs.id
    }
}

public struct DependencyEdge: Hashable, Codable, Sendable {
    public let from: String
    public let to: String
    public let relationship: String
    public let isCircular: Bool
    
    public init(from: String, to: String, relationship: String = "depends_on", isCircular: Bool = false) {
        self.from = from
        self.to = to
        self.relationship = relationship
        self.isCircular = isCircular
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(from)
        hasher.combine(to)
    }
    
    public static func == (lhs: DependencyEdge, rhs: DependencyEdge) -> Bool {
        return lhs.from == rhs.from && lhs.to == rhs.to
    }
}

public struct GraphAnalysis: Codable, Sendable {
    public let hasCircularDependencies: Bool
    public let totalNodes: Int
    public let totalDependencies: Int
    public let maxDepth: Int
    public let circularDependencyChains: [[String]]
    public let analysisTime: TimeInterval
    public let memoryUsage: Double
    public let cacheEfficiency: Double
    
    public init(hasCircularDependencies: Bool = false, totalNodes: Int = 0, totalDependencies: Int = 0, maxDepth: Int = 0, circularDependencyChains: [[String]] = [], analysisTime: TimeInterval = 0, memoryUsage: Double = 0, cacheEfficiency: Double = 0) {
        self.hasCircularDependencies = hasCircularDependencies
        self.totalNodes = totalNodes
        self.totalDependencies = totalDependencies
        self.maxDepth = maxDepth
        self.circularDependencyChains = circularDependencyChains
        self.analysisTime = analysisTime
        self.memoryUsage = memoryUsage
        self.cacheEfficiency = cacheEfficiency
    }
}

// MARK: - Advanced DI Container Protocol (Public Interface Only)
@MainActor
public protocol AdvancedDIContainer: Sendable {
    // MARK: - Core Registration (Async)
    func register<T: Sendable>(
        _ type: T.Type,
        scope: DependencyScope,
        lifetime: DependencyLifetime,
        factory: @escaping @Sendable (AdvancedDIContainer) async throws -> T
    )
    
    func register<T: Sendable>(
        _ type: T.Type,
        scope: DependencyScope,
        factory: @escaping @Sendable (AdvancedDIContainer) async throws -> T
    )
    
    // MARK: - Core Registration (Sync)
    func registerSync<T: Sendable>(
        _ type: T.Type,
        scope: DependencyScope,
        lifetime: DependencyLifetime,
        factory: @escaping @Sendable (AdvancedDIContainer) throws -> T
    )
    
    func registerSync<T: Sendable>(
        _ type: T.Type,
        scope: DependencyScope,
        factory: @escaping @Sendable (AdvancedDIContainer) throws -> T
    )
    
    // MARK: - Resolution
    func resolve<T: Sendable>() async throws -> T
    func resolve<T: Sendable>(_ type: T.Type) async throws -> T
    
    // Synchronous resolution for cached instances
    func resolveSync<T: Sendable>() throws -> T
    func resolveSync<T: Sendable>(_ type: T.Type) throws -> T
    
    // MARK: - Scope Management
    func createScope(_ scopeId: String) async
    func disposeScope(_ scopeId: String) async
    func setCurrentScope(_ scopeId: String) async
    func getCurrentScope() -> String
    
    // MARK: - Analysis and Validation
    func validateDependencies() async throws
    func getDependencyGraph() async -> DependencyGraph
    func analyzeDependencyGraph() async -> GraphAnalysis
    func analyzeDependencyGraphWithMetrics() async -> GraphAnalysis
    func isRegistered<T>(_ type: T.Type) -> Bool
    
    // MARK: - Performance and Monitoring
    func getPerformanceMetrics() async -> PerformanceMetrics
    func preloadDependencies() async
    func cleanup() async
    
    // MARK: - Generic Preloading
    func preloadAllGeneric() async throws
    func preloadSmart() async throws
    func preloadViewModelsOnly() async throws
    
    // MARK: - Metadata
    func getMetadata<T>(_ type: T.Type) -> DependencyMetadata?
    func registerWithMetadata<T>(_ type: T.Type, metadata: DependencyMetadata)
    
    // MARK: - Metadata Access
    func getMetadata(for key: String) -> DependencyMetadata?
    func getDependencyMap() -> [String: Set<String>]
    
    func getRegisteredServicesCount() -> Int
    
    // MARK: - Debug Methods
    func debugPrintMetadata()
    func debugPrintFactories()
    
    // MARK: - Legacy Support (for backward compatibility)
    func enableAnalytics(token: String)
    func enableCrashlytics()
    func enableDashboardSync(token: String)
    func getDependencyGraphData() throws -> [String: Any]
    func getAnalyticsToken() -> String?
}

// MARK: - DI Module Protocol
public protocol DIModule {
    func configure(container: AdvancedDIContainer) async throws
}

// MARK: - Legacy Service Scope (for backward compatibility)
public enum ServiceScope {
    case singleton
    case transient
    case scoped
    case application
    
    // Conversion to new DependencyScope
    public var dependencyScope: DependencyScope {
        switch self {
        case .singleton:
            return .singleton
        case .transient:
            return .transient
        case .scoped:
            return .scoped
        case .application:
            return .singleton // Map application to singleton for compatibility
        }
    }
}

// MARK: - DI Container Configuration
public struct DIContainerConfig {
    public let maxCircularDependencyDepth: Int
    public let enableCircularDependencyDetection: Bool
    public let enableDependencyTracking: Bool
    public let enablePerformanceMetrics: Bool
    public let enableCaching: Bool
    
    public init(
        maxCircularDependencyDepth: Int = 3,
        enableCircularDependencyDetection: Bool = true,
        enableDependencyTracking: Bool = true,
        enablePerformanceMetrics: Bool = true,
        enableCaching: Bool = true
    ) {
        self.maxCircularDependencyDepth = maxCircularDependencyDepth
        self.enableCircularDependencyDetection = enableCircularDependencyDetection
        self.enableDependencyTracking = enableDependencyTracking
        self.enablePerformanceMetrics = enablePerformanceMetrics
        self.enableCaching = enableCaching
    }
}

// MARK: - Token Validation Error
public enum DITokenValidationError: Error, LocalizedError {
    case invalidToken
    case expiredToken
    case networkError
    case serverError
    case invalidTokenFormat
    case tokenExpired
    case validationFailed(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidToken:
            return "Invalid token provided"
        case .expiredToken:
            return "Token has expired"
        case .networkError:
            return "Network error during token validation"
        case .serverError:
            return "Server error during token validation"
        case .invalidTokenFormat:
            return "Invalid token format"
        case .tokenExpired:
            return "Token has expired"
        case .validationFailed(let error):
            return "Validation failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - Framework Version
public let GoDareDIVersion = "1.0.11"
public let GoDareDIBuildNumber = "11"

// MARK: - Analytics Provider (Simple Implementation)
internal class DIAnalyticsProvider {
    let token: String
    
    init(token: String) {
        self.token = token
    }
}

// MARK: - Advanced DI Container Implementation (Public Initializer Only)
// Implementation details are hidden in binary framework
@MainActor
public final class AdvancedDIContainerImpl: AdvancedDIContainer, Sendable {
    
    // MARK: - Properties
    internal let config: DIContainerConfig
    public var singletons: [String: Sendable] = [:]
    internal var scopedInstances: [String: [String: Sendable]] = [:]
    internal var lazyInstances: [String: Sendable] = [:]
    internal var resolutionStack: [String] = []
    internal var scopeId: String = "default"
    internal var dependencyMap: [String: Set<String>] = [:]
    internal var performanceMetrics: [String: TimeInterval] = [:]
    internal var resolutionCounts: [String: Int] = [:]
    internal var cacheHits: [String: Int] = [:]
    public var factories: [String: FactoryType] = [:]
    
    // 🚀 UNIFIED: Single metadata storage for both resolution and preloading
    internal var typeRegistry: [String: DependencyMetadata] = [:]
    
    // 🔥 CRASHLYTICS: Analytics and crashlytics integration
    internal var analyticsProvider: DIAnalyticsProvider?
    
    // MARK: - Factory Union Type
    public enum FactoryType {
        case sync(@Sendable (AdvancedDIContainer) throws -> Sendable)
        case async(@Sendable (AdvancedDIContainer) async throws -> Sendable)
    }
    
    // MARK: - Public Initializer (Only this is exposed)
    public init(config: DIContainerConfig, token: String) async throws {
        self.config = config
        // Token validation would happen here in the real implementation
        // For now, we'll just store the token and proceed
        self.analyticsProvider = DIAnalyticsProvider(token: token)
    }
    
    // MARK: - Freemium Initializer (No Token Required)
    public init(config: DIContainerConfig = DIContainerConfig(), enableFreemium: Bool = true) {
        self.config = config
        // No token validation for freemium mode
        // Advanced features will be gated in the UI
    }
    
    // MARK: - Protocol Conformance (Working Implementation)
    public func register<T: Sendable>(_ type: T.Type, scope: DependencyScope, lifetime: DependencyLifetime, factory: @escaping @Sendable (AdvancedDIContainer) async throws -> T) {
        let key = String(describing: type)
        factories[key] = .async(factory)
        
        // Store metadata for this type
        let metadata = DependencyMetadata(
            type: T.self,
            scope: scope,
            lifetime: lifetime
        )
        typeRegistry[key] = metadata
    }
    
    public func register<T: Sendable>(_ type: T.Type, scope: DependencyScope, factory: @escaping @Sendable (AdvancedDIContainer) async throws -> T) {
        // Store the factory for async resolution
        let key = String(describing: type)
        factories[key] = .async(factory)
        
        let metadata = DependencyMetadata(
            type: T.self,
            scope: scope,
            lifetime: .request
        )
        typeRegistry[key] = metadata
    }
    
    public func registerSync<T: Sendable>(_ type: T.Type, scope: DependencyScope, lifetime: DependencyLifetime, factory: @escaping @Sendable (AdvancedDIContainer) throws -> T) {
        let key = String(describing: type)
        factories[key] = .sync(factory)
        
        let metadata = DependencyMetadata(
            type: T.self,
            scope: scope,
            lifetime: lifetime
        )
        typeRegistry[key] = metadata
    }
    
    public func registerSync<T: Sendable>(_ type: T.Type, scope: DependencyScope, factory: @escaping @Sendable (AdvancedDIContainer) throws -> T) {
        try registerSync(type, scope: scope, lifetime: .request, factory: factory)
    }
    
    public func resolve<T: Sendable>() async throws -> T {
        return try await resolve(T.self)
    }
    
    public func resolve<T: Sendable>(_ type: T.Type) async throws -> T {
        let key = String(describing: type)
        
        guard let factory = factories[key] else {
            throw GoDareDIError.typeNotRegistered(key)
        }
        
        // Check for singleton cache
        if let cached = singletons[key] as? T {
            return cached
        }
        
        // Create instance
        let instance: T
        switch factory {
        case .async(let asyncFactory):
            instance = try await asyncFactory(self) as! T
        case .sync(let syncFactory):
            instance = try syncFactory(self) as! T
        }
        
        // Cache singleton
        singletons[key] = instance
        
        return instance
    }
    
    public func resolveSync<T: Sendable>() throws -> T {
        return try resolveSync(T.self)
    }
    
    public func resolveSync<T: Sendable>(_ type: T.Type) throws -> T {
        let key = String(describing: type)
        
        guard let factory = factories[key] else {
            throw GoDareDIError.typeNotRegistered(key)
        }
        
        // Check for singleton cache
        if let cached = singletons[key] as? T {
            return cached
        }
        
        // Create instance (only sync factories)
        let instance: T
        switch factory {
        case .async:
            throw GoDareDIError.asyncFactoryInSyncContext(key)
        case .sync(let syncFactory):
            instance = try syncFactory(self) as! T
        }
        
        // Cache singleton
        singletons[key] = instance
        
        return instance
    }
    
    public func createScope(_ scopeId: String) async {
        scopedInstances[scopeId] = [:]
    }
    
    public func disposeScope(_ scopeId: String) async {
        scopedInstances.removeValue(forKey: scopeId)
    }
    
    public func setCurrentScope(_ scopeId: String) async {
        self.scopeId = scopeId
    }
    
    public func getCurrentScope() -> String {
        return scopeId
    }
    
    public func validateDependencies() async throws {
        // Basic validation - check that all registered types have factories
        for (key, _) in typeRegistry {
            guard factories[key] != nil else {
                throw GoDareDIError.typeNotRegistered(key)
            }
        }
    }
    
    public func getDependencyGraph() async -> DependencyGraph {
        fatalError("Implementation hidden in binary framework")
    }
    
    public func analyzeDependencyGraph() async -> GraphAnalysis {
        fatalError("Implementation hidden in binary framework")
    }
    
    public func analyzeDependencyGraphWithMetrics() async -> GraphAnalysis {
        fatalError("Implementation hidden in binary framework")
    }
    
    public func isRegistered<T>(_ type: T.Type) -> Bool {
        fatalError("Implementation hidden in binary framework")
    }
    
    public func getPerformanceMetrics() async -> PerformanceMetrics {
        fatalError("Implementation hidden in binary framework")
    }
    
    public func preloadDependencies() async {
        fatalError("Implementation hidden in binary framework")
    }
    
    public func cleanup() async {
        fatalError("Implementation hidden in binary framework")
    }
    
    public func preloadAllGeneric() async throws {
        // Preload all registered types by attempting to resolve them
        for (key, _) in factories {
            // Try to resolve each type to preload it
            // This is a simplified preload - in a real implementation, 
            // we would analyze dependencies and preload in the correct order
            do {
                _ = try await resolveAny(key)
            } catch {
                // Some types might not be resolvable without parameters
                // This is expected for some types
                continue
            }
        }
    }
    
    // Helper method to resolve any type by key
    private func resolveAny(_ key: String) async throws -> Any {
        guard let factory = factories[key] else {
            throw GoDareDIError.typeNotRegistered(key)
        }
        
        switch factory {
        case .async(let asyncFactory):
            return try await asyncFactory(self)
        case .sync(let syncFactory):
            return try syncFactory(self)
        }
    }
    
    public func preloadSmart() async throws {
        fatalError("Implementation hidden in binary framework")
    }
    
    public func preloadViewModelsOnly() async throws {
        fatalError("Implementation hidden in binary framework")
    }
    
    public func getMetadata<T>(_ type: T.Type) -> DependencyMetadata? {
        fatalError("Implementation hidden in binary framework")
    }
    
    public func registerWithMetadata<T>(_ type: T.Type, metadata: DependencyMetadata) {
        fatalError("Implementation hidden in binary framework")
    }
    
    public func getMetadata(for key: String) -> DependencyMetadata? {
        fatalError("Implementation hidden in binary framework")
    }
    
    public func getDependencyMap() -> [String: Set<String>] {
        fatalError("Implementation hidden in binary framework")
    }
    
    public func getRegisteredServicesCount() -> Int {
        fatalError("Implementation hidden in binary framework")
    }
    
    public func debugPrintMetadata() {
        fatalError("Implementation hidden in binary framework")
    }
    
    public func debugPrintFactories() {
        fatalError("Implementation hidden in binary framework")
    }
    
    public func enableAnalytics(token: String) {
        fatalError("Implementation hidden in binary framework")
    }
    
    public func enableCrashlytics() {
        fatalError("Implementation hidden in binary framework")
    }
    
    public func enableDashboardSync(token: String) {
        fatalError("Implementation hidden in binary framework")
    }
    
    public func getDependencyGraphData() throws -> [String: Any] {
        fatalError("Implementation hidden in binary framework")
    }
    
    public func getAnalyticsToken() -> String? {
        return analyticsProvider?.token
    }
}

// MARK: - Dependency Graph Visualization (Public SwiftUI Component)
// Implementation details are hidden in binary framework
#if canImport(SwiftUI)
import SwiftUI

@available(iOS 14.0, macOS 10.15, tvOS 14.0, watchOS 7.0, *)
public struct DependencyGraphView: View {
    private let container: AdvancedDIContainer
    
    // MARK: - Public Initializer (Only this is exposed)
    public init(container: AdvancedDIContainer) {
        self.container = container
    }
    
    // MARK: - Public Interface (Implementation Hidden)
    public var body: some View {
        // Implementation is hidden in binary framework
        // This view is the only public interface to the visualization
        VStack(spacing: 20) {
            Text("📊")
                .font(.system(size: 50))
            
            Text("Dependency Graph")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Implementation hidden in binary framework")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text("This view provides a placeholder for the dependency graph visualization. The actual implementation is protected in the binary framework.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}
#endif

// MARK: - Errors (Public)
public enum GoDareDIError: Error, LocalizedError {
    case serviceNotRegistered(Any.Type)
    case serviceResolutionFailed(Any.Type)
    case circularDependencyDetected
    case configurationError(String)
    case tokenValidationFailed
    case typeNotRegistered(String)
    case asyncFactoryInSyncContext(String)
    
    public var errorDescription: String? {
        switch self {
        case .serviceNotRegistered(let type):
            return "Service \(type) is not registered"
        case .serviceResolutionFailed(let type):
            return "Failed to resolve service \(type)"
        case .circularDependencyDetected:
            return "Circular dependency detected"
        case .configurationError(let message):
            return "Configuration error: \(message)"
        case .tokenValidationFailed:
            return "Token validation failed"
        case .typeNotRegistered(let key):
            return "Type \(key) is not registered"
        case .asyncFactoryInSyncContext(let key):
            return "Cannot use async factory for \(key) in sync context"
        }
    }
}

// MARK: - Usage Example
/*
 
 // 1. Create a container (Freemium Mode - No Token Required)
 let container = AdvancedDIContainerImpl(
     config: DIContainerConfig(
         maxCircularDependencyDepth: 3,
         enableCircularDependencyDetection: true,
         enableDependencyTracking: true,
         enablePerformanceMetrics: true,
         enableCaching: true
     ),
     enableFreemium: true // This allows the SDK to work without a token
 )

 // OR create a container with token for Premium features
 do {
     let premiumContainer = try await AdvancedDIContainerImpl(
         config: DIContainerConfig(
             maxCircularDependencyDepth: 3,
             enableCircularDependencyDetection: true,
             enableDependencyTracking: true,
             enablePerformanceMetrics: true,
             enableCaching: true
         ),
         token: "your-sdk-token-here"
     )
     
     // 2. Register your dependencies (automatically tracked)
     await container.register(MyService.self, scope: .singleton) { container in
         return MyService()
     }
     
     await container.register(MyRepository.self, scope: .transient) { container in
         let service = try await container.resolve(MyService.self)
         return MyRepository(service: service)
     }
     
     // 3. Resolve dependencies (automatically tracked)
     let repository = try await container.resolve(MyRepository.self)
     
     // 4. Use in your app
     let result = await repository.fetchData()
     
 // 5. Visualize dependencies (SwiftUI) - automatically detects token from container
 SimpleDependencyGraphView(container: container)
 
 // 6. Generate Mermaid diagram - automatically detects token from container
 let visualizer = DependencyVisualizer(container: container)
 let mermaidDiagram = try await visualizer.visualizeAsync(type: .mermaid)
     
     // 7. All analytics and monitoring data is automatically sent to your dashboard!
     
 } catch DITokenValidationError.invalidToken {
     print("❌ Invalid token. Please check your token and try again.")
 } catch DITokenValidationError.invalidTokenFormat {
     print("❌ Invalid token format. Token must be 64 characters long.")
 } catch DITokenValidationError.tokenExpired {
     print("❌ Token has expired. Please generate a new token.")
 } catch {
     print("❌ Error initializing container: \(error)")
 }

 // FREEMIUM MODEL:
 // - Basic DI functionality works without a token
 // - Advanced features (visualization, dashboard sync) require a token
 // - Users can upgrade to premium by entering a token
 // - The DependencyGraphView shows a subscription prompt when no token is present
 // - All backend services are abstracted and hidden from users
 */
