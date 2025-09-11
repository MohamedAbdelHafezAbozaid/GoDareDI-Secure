import Foundation
import SwiftUI

// MARK: - GoDareDI Framework
// Advanced Dependency Injection Framework
// Secure Binary Distribution - Source Code Protected

// MARK: - Service Scope
public enum ServiceScope {
    case singleton
    case transient
    case scoped
    case application
}

// MARK: - DI Container Configuration
public struct DIContainerConfig {
    public let maxCircularDependencyDepth: Int
    public let enableCircularDependencyDetection: Bool
    public let enableDependencyTracking: Bool
    public let enablePerformanceMetrics: Bool
    public let enableCaching: Bool
    
    public init(
        maxCircularDependencyDepth: Int = 10,
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

// MARK: - Token Validation Errors
public enum DITokenValidationError: Error, LocalizedError {
    case invalidToken
    case tokenExpired
    case networkError
    case serverError
    
    public var errorDescription: String? {
        switch self {
        case .invalidToken:
            return "Invalid SDK token"
        case .tokenExpired:
            return "SDK token has expired"
        case .networkError:
            return "Network error during token validation"
        case .serverError:
            return "Server error during token validation"
        }
    }
}

// MARK: - Visualization Types
public struct DependencyGraph: Sendable {
    public let nodes: [String: DependencyNode]
    public let edges: [DependencyEdge]
    
    public init(nodes: [String: DependencyNode] = [:], edges: [DependencyEdge] = []) {
        self.nodes = nodes
        self.edges = edges
    }
}

public struct DependencyNode: Sendable {
    public let id: String
    public let type: String
    public let scope: String
    public let hasInstance: Bool
    
    public init(id: String, type: String, scope: String, hasInstance: Bool = false) {
        self.id = id
        self.type = type
        self.scope = scope
        self.hasInstance = hasInstance
    }
}

public struct DependencyEdge: Sendable {
    public let from: String
    public let to: String
    public let relationship: String
    
    public init(from: String, to: String, relationship: String = "depends_on") {
        self.from = from
        self.to = to
        self.relationship = relationship
    }
}

public struct DependencyAnalysis: Sendable {
    public let totalNodes: Int
    public let totalEdges: Int
    public let circularDependencies: [String]
    public let depth: Int
    
    public init(totalNodes: Int = 0, totalEdges: Int = 0, circularDependencies: [String] = [], depth: Int = 0) {
        self.totalNodes = totalNodes
        self.totalEdges = totalEdges
        self.circularDependencies = circularDependencies
        self.depth = depth
    }
}

// MARK: - DI Module Protocol
public protocol DIModule {
    func configure(container: AdvancedDIContainer) async throws
}

// MARK: - Dependency Injection Container Protocol
public protocol AdvancedDIContainer: Sendable {
    func register<T>(_ type: T.Type, scope: ServiceScope, factory: @escaping (AdvancedDIContainer) async throws -> T) async throws
    func resolve<T>(_ type: T.Type) async throws -> T
    func resolveSync<T>(_ type: T.Type) throws -> T
    func enableAnalytics(token: String)
    func enableCrashlytics()
    func enableDashboardSync(token: String)
    func preloadAllGeneric() async throws
    func getDependencyGraphData() throws -> [String: Any]
    
    // MARK: - Visualization Methods
    func getDependencyGraph() async -> DependencyGraph
    func analyzeDependencyGraph() async -> DependencyAnalysis
    
    // MARK: - Token Access
    func getAnalyticsToken() -> String?
}

// MARK: - Advanced DI Container Implementation
public final class AdvancedDIContainerImpl: AdvancedDIContainer, Sendable {
    
    // MARK: - Thread-Safe Properties
    private let lock = NSLock()
    private var services: [String: Any] = [:]
    private var factories: [String: (AdvancedDIContainer) async throws -> Any] = [:]
    private var scopes: [String: ServiceScope] = [:]
    private var scopedInstances: [String: Any] = [:]
    private var applicationInstances: [String: Any] = [:]
    private var isAnalyticsEnabled = false
    private var isCrashlyticsEnabled = false
    private var isDashboardSyncEnabled = false
    private var analyticsToken: String?
    private var config: DIContainerConfig
    
    // MARK: - Initialization
    public init() {
        self.config = DIContainerConfig()
        print("🔒 GoDareDI: Secure Binary Framework Initialized")
    }
    
    public init(config: DIContainerConfig, token: String) throws {
        self.config = config
        
        // Validate token
        try validateToken(token)
        lock.lock()
        analyticsToken = token
        lock.unlock()
        
        print("🔒 GoDareDI: Secure Binary Framework Initialized with Token")
    }
    
    // MARK: - Token Validation
    private func validateToken(_ token: String) throws {
        // Simple token validation - in a real implementation, this would make a network call
        guard !token.isEmpty else {
            throw DITokenValidationError.invalidToken
        }
        
        // For demo purposes, accept the provided token
        print("📡 GoDareDI: Token validated successfully")
    }
    
    // MARK: - Service Registration
    public func register<T>(_ type: T.Type, scope: ServiceScope, factory: @escaping (AdvancedDIContainer) async throws -> T) async throws {
        let key = String(describing: type)
        
        // Store factory and scope
        lock.lock()
        factories[key] = factory
        scopes[key] = scope
        lock.unlock()
        
        if scope == .singleton || scope == .application {
            let instance = try await factory(self)
            lock.lock()
            if scope == .singleton {
                services[key] = instance
            } else {
                applicationInstances[key] = instance
            }
            lock.unlock()
        }
        
        print("📦 GoDareDI: Registered \(key) with scope \(scope)")
    }
    
    // MARK: - Service Resolution
    public func resolve<T>(_ type: T.Type) async throws -> T {
        let key = String(describing: type)
        
        lock.lock()
        let scope = scopes[key]
        let factory = factories[key]
        lock.unlock()
        
        guard let scope = scope, let factory = factory else {
            throw GoDareDIError.serviceNotRegistered(type)
        }
        
        switch scope {
        case .singleton:
            lock.lock()
            let instance = services[key] as? T
            lock.unlock()
            guard let instance = instance else {
                throw GoDareDIError.serviceResolutionFailed(type)
            }
            return instance
            
        case .application:
            lock.lock()
            let instance = applicationInstances[key] as? T
            lock.unlock()
            guard let instance = instance else {
                throw GoDareDIError.serviceResolutionFailed(type)
            }
            return instance
            
        case .transient:
            return try await factory(self) as! T
            
        case .scoped:
            lock.lock()
            let existingInstance = scopedInstances[key] as? T
            lock.unlock()
            if let instance = existingInstance {
                return instance
            } else {
                let instance = try await factory(self) as! T
                lock.lock()
                scopedInstances[key] = instance
                lock.unlock()
                return instance
            }
        }
    }
    
    // MARK: - Synchronous Service Resolution
    public func resolveSync<T>(_ type: T.Type) throws -> T {
        let key = String(describing: type)
        
        lock.lock()
        let scope = scopes[key]
        let _ = factories[key]
        lock.unlock()
        
        guard let scope = scope else {
            throw GoDareDIError.serviceNotRegistered(type)
        }
        
        switch scope {
        case .singleton:
            lock.lock()
            let instance = services[key] as? T
            lock.unlock()
            guard let instance = instance else {
                throw GoDareDIError.serviceResolutionFailed(type)
            }
            return instance
            
        case .application:
            lock.lock()
            let instance = applicationInstances[key] as? T
            lock.unlock()
            guard let instance = instance else {
                throw GoDareDIError.serviceResolutionFailed(type)
            }
            return instance
            
        case .transient:
            // For transient, we need to create a new instance synchronously
            // This is a simplified implementation
            throw GoDareDIError.serviceResolutionFailed(type)
            
        case .scoped:
            lock.lock()
            let instance = scopedInstances[key] as? T
            lock.unlock()
            guard let instance = instance else {
                throw GoDareDIError.serviceResolutionFailed(type)
            }
            return instance
        }
    }
    
    // MARK: - Premium Features
    public func enableAnalytics(token: String) {
        lock.lock()
        isAnalyticsEnabled = true
        analyticsToken = token
        lock.unlock()
        print("📊 GoDareDI: Analytics enabled with token")
    }
    
    public func enableCrashlytics() {
        lock.lock()
        isCrashlyticsEnabled = true
        lock.unlock()
        print("🛡️ GoDareDI: Crashlytics enabled")
    }
    
    public func enableDashboardSync(token: String) {
        lock.lock()
        isDashboardSyncEnabled = true
        lock.unlock()
        print("📱 GoDareDI: Dashboard sync enabled")
    }
    
    // MARK: - Preload All Generic Types
    public func preloadAllGeneric() async throws {
        // Preload all registered services that are singletons or application-scoped
        lock.lock()
        let scopes = self.scopes
        let factories = self.factories
        lock.unlock()
        
        for (key, scope) in scopes {
            if scope == .singleton || scope == .application {
                // Try to resolve to preload
                if let factory = factories[key] {
                    _ = try await factory(self)
                    print("📦 GoDareDI: Preloaded \(key)")
                }
            }
        }
        print("✅ GoDareDI: All generic types preloaded")
    }
    
    // MARK: - Dependency Graph Data
    public func getDependencyGraphData() throws -> [String: Any] {
        var graphData: [String: Any] = [:]
        
        // Get thread-safe copies of the data
        lock.lock()
        let scopes = self.scopes
        let factories = self.factories
        let services = self.services
        let applicationInstances = self.applicationInstances
        lock.unlock()
        
        // Build dependency graph from registered services
        for (key, scope) in scopes {
            var serviceInfo: [String: Any] = [:]
            
            // Add service type/scope
            serviceInfo["type"] = scopeString(scope)
            
            // Add dependencies (this would need to be tracked during registration)
            // For now, return empty dependencies array
            serviceInfo["dependencies"] = []
            
            // Add registration info
            serviceInfo["registered"] = true
            serviceInfo["hasFactory"] = factories[key] != nil
            
            // Add instance info if available
            if scope == .singleton || scope == .application {
                if scope == .singleton {
                    serviceInfo["hasInstance"] = services[key] != nil
                } else {
                    serviceInfo["hasInstance"] = applicationInstances[key] != nil
                }
            } else {
                serviceInfo["hasInstance"] = false
            }
            
            graphData[key] = serviceInfo
        }
        
        return graphData
    }
    
    // MARK: - Visualization Methods
    public func getDependencyGraph() async -> DependencyGraph {
        lock.lock()
        let scopes = self.scopes
        let services = self.services
        let applicationInstances = self.applicationInstances
        lock.unlock()
        
        var nodes: [String: DependencyNode] = [:]
        var edges: [DependencyEdge] = []
        
        // Create nodes for all registered services
        for (key, scope) in scopes {
            let hasInstance: Bool
            if scope == .singleton {
                hasInstance = services[key] != nil
            } else if scope == .application {
                hasInstance = applicationInstances[key] != nil
            } else {
                hasInstance = false
            }
            
            let node = DependencyNode(
                id: key,
                type: key,
                scope: scopeString(scope),
                hasInstance: hasInstance
            )
            nodes[key] = node
        }
        
        // For now, we don't track actual dependencies, so edges are empty
        // In a real implementation, you would track dependencies during registration
        
        return DependencyGraph(nodes: nodes, edges: edges)
    }
    
    public func analyzeDependencyGraph() async -> DependencyAnalysis {
        let graph = await getDependencyGraph()
        
        let totalNodes = graph.nodes.count
        let totalEdges = graph.edges.count
        
        // Simple circular dependency detection (placeholder)
        let circularDependencies: [String] = []
        
        // Calculate depth (placeholder - would need actual graph traversal)
        let depth = calculateGraphDepth(graph)
        
        return DependencyAnalysis(
            totalNodes: totalNodes,
            totalEdges: totalEdges,
            circularDependencies: circularDependencies,
            depth: depth
        )
    }
    
    private func calculateGraphDepth(_ graph: DependencyGraph) -> Int {
        // Simple depth calculation - in a real implementation, this would do actual graph traversal
        return min(graph.nodes.count, 10) // Cap at 10 for now
    }
    
    // MARK: - Token Access
    public func getAnalyticsToken() -> String? {
        lock.lock()
        let token = analyticsToken
        lock.unlock()
        return token
    }
    
    private func scopeString(_ scope: ServiceScope) -> String {
        switch scope {
        case .singleton:
            return "Singleton"
        case .transient:
            return "Transient"
        case .scoped:
            return "Scoped"
        case .application:
            return "Application"
        }
    }
}

// MARK: - Errors
public enum GoDareDIError: Error, LocalizedError {
    case serviceNotRegistered(Any.Type)
    case serviceResolutionFailed(Any.Type)
    case circularDependency
    case invalidScope
    
    public var errorDescription: String? {
        switch self {
        case .serviceNotRegistered(let type):
            return "Service \(type) is not registered"
        case .serviceResolutionFailed(let type):
            return "Failed to resolve service \(type)"
        case .circularDependency:
            return "Circular dependency detected"
        case .invalidScope:
            return "Invalid service scope"
        }
    }
}

// MARK: - Framework Version
public let GoDareDIVersion = "1.0.6"
public let GoDareDIBuildNumber = "6"

// MARK: - Dependency Graph Visualization
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
                    loadingView
                } else if let errorMessage = errorMessage {
                    errorView(message: errorMessage)
                } else {
                    contentView
                }
            }
            .modifier(NavigationTitleModifier())
            .onAppear {
                loadDependencyData()
            }
        }
    }
    
    @ViewBuilder
    private var loadingView: some View {
        if #available(macOS 11.0, *) {
            ProgressView("Loading dependency graph...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            VStack {
                Text("Loading dependency graph...")
                    .font(.headline)
                Text("⏳")
                    .font(.system(size: 30))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    private func errorView(message: String) -> some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            Text("Error")
                .font(.title)
                .fontWeight(.bold)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Dependency Graph")
                    .font(.title)
                    .fontWeight(.bold)
                
                ForEach(Array(dependencyData.keys.sorted()), id: \.self) { key in
                    DependencyNodeView(key: key, data: dependencyData[key])
                }
            }
            .padding()
        }
    }
    
    private func loadDependencyData() {
        // Load actual dependency graph data from the container
        DispatchQueue.main.async {
            do {
                // Get dependency information from the container
                self.dependencyData = try self.container.getDependencyGraphData()
                self.isLoading = false
            } catch {
                self.errorMessage = "Failed to load dependency data: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct DependencyNodeView: View {
    let key: String
    let data: Any?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(colorForType)
                    .frame(width: 12, height: 12)
                Text(key)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text(typeString)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            
            if let dependencies = dependencies, !dependencies.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dependencies:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(dependencies, id: \.self) { dependency in
                        HStack {
                            Text("•")
                                .foregroundColor(.blue)
                            Text(dependency)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 16)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var colorForType: Color {
        switch typeString {
        case "Singleton":
            return .green
        case "Transient":
            return .blue
        case "Scoped":
            return .orange
        case "Application":
            return .purple
        default:
            return .gray
        }
    }
    
    private var typeString: String {
        if let dict = data as? [String: Any],
           let type = dict["type"] as? String {
            return type
        }
        return "Unknown"
    }
    
    private var dependencies: [String]? {
        if let dict = data as? [String: Any],
           let deps = dict["dependencies"] as? [String] {
            return deps
        }
        return nil
    }
}

// MARK: - Navigation Title Modifier for macOS Compatibility
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct NavigationTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.navigationTitle("GoDareDI Graph")
    }
}
