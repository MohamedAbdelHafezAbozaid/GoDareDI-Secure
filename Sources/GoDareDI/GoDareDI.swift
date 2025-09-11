//
//  GoDareDI.swift
//  GoDareDI-Secure
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation
import SwiftUI

// MARK: - GoDareDI-Secure Framework
// Advanced Dependency Injection Framework
// Protocol-Only Distribution - Implementation Protected

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

// MARK: - Advanced DI Container Protocol
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
        }
    }
}

// MARK: - Framework Version
public let GoDareDIVersion = "1.0.7"
public let GoDareDIBuildNumber = "7"

// MARK: - Dependency Graph Visualization (Public SwiftUI Component)
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public struct DependencyGraphView: View {
    private let container: AdvancedDIContainer
    @State private var dependencyData: [String: Any] = [:]
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    public init(container: AdvancedDIContainer) {
        self.container = container
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading dependency graph...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let error = errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("Error loading graph")
                            .font(.headline)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    DependencyGraphContentView(data: dependencyData)
                }
            }
            .navigationTitle("Dependency Graph")
            .onAppear {
                loadDependencyData()
            }
        }
    }
    
    private func loadDependencyData() {
        isLoading = true
        errorMessage = nil
        
        do {
            self.dependencyData = try container.getDependencyGraphData()
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
}

// MARK: - Private Implementation (Hidden from Public API)
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct DependencyGraphContentView: View {
    let data: [String: Any]
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                ForEach(Array(data.keys.sorted()), id: \.self) { key in
                    if let serviceInfo = data[key] as? [String: Any] {
                        DependencyNodeView(key: key, info: serviceInfo)
                    }
                }
            }
            .padding()
        }
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct DependencyNodeView: View {
    let key: String
    let info: [String: Any]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "circle.fill")
                    .foregroundColor(nodeColor)
                    .font(.caption)
                
                Text(key)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if let hasInstance = info["hasInstance"] as? Bool, hasInstance {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            
            if let type = info["type"] as? String {
                Text(type)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                if let registered = info["registered"] as? Bool, registered {
                    Label("Registered", systemImage: "checkmark.circle")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                if let hasFactory = info["hasFactory"] as? Bool, hasFactory {
                    Label("Factory", systemImage: "wrench")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var nodeColor: Color {
        if let hasInstance = info["hasInstance"] as? Bool, hasInstance {
            return .green
        } else if let registered = info["registered"] as? Bool, registered {
            return .blue
        } else {
            return .gray
        }
    }
}

// MARK: - Errors (Public)
public enum GoDareDIError: Error, LocalizedError {
    case serviceNotRegistered(Any.Type)
    case serviceResolutionFailed(Any.Type)
    case circularDependencyDetected
    case configurationError(String)
    case tokenValidationFailed
    
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
        }
    }
}

// MARK: - Usage Example
/*
 
 // 1. Create a container (Protocol-Only - Implementation Hidden)
 let container: AdvancedDIContainer = AdvancedDIContainerImpl(
     config: DIContainerConfig(
         maxCircularDependencyDepth: 3,
         enableCircularDependencyDetection: true,
         enableDependencyTracking: true,
         enablePerformanceMetrics: true,
         enableCaching: true
     ),
     token: "your-secure-token-here"
 )
 
 // 2. Register services using the protocol
 await container.register(MyService.self, scope: .singleton) { container in
     return MyService()
 }
 
 // 3. Resolve services
 let service = try await container.resolve(MyService.self)
 
 // 4. Use the DependencyGraphView (Public SwiftUI Component)
 DependencyGraphView(container: container)
 
 // 5. Get dependency graph data
 let graph = await container.getDependencyGraph()
 let analysis = await container.analyzeDependencyGraph()
 
 */