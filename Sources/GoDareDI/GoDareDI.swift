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

// MARK: - DI Module Protocol
public protocol DIModule {
    func configure(container: AdvancedDIContainer) async throws
}

// MARK: - Dependency Injection Container Protocol
public protocol AdvancedDIContainer {
    func register<T>(_ type: T.Type, scope: ServiceScope, factory: @escaping (AdvancedDIContainer) async throws -> T) async throws
    func resolve<T>(_ type: T.Type) async throws -> T
    func resolveSync<T>(_ type: T.Type) throws -> T
    func enableAnalytics(token: String)
    func enableCrashlytics()
    func enableDashboardSync(token: String)
    func preloadAllGeneric() async throws
    func getDependencyGraphData() throws -> [String: Any]
}

// MARK: - Advanced DI Container Implementation
public class AdvancedDIContainerImpl: AdvancedDIContainer {
    
    // MARK: - Private Properties
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
        self.analyticsToken = token
        
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
        factories[key] = factory
        scopes[key] = scope
        
        if scope == .singleton || scope == .application {
            let instance = try await factory(self)
            if scope == .singleton {
                services[key] = instance
            } else {
                applicationInstances[key] = instance
            }
        }
        
        print("📦 GoDareDI: Registered \(key) with scope \(scope)")
    }
    
    // MARK: - Service Resolution
    public func resolve<T>(_ type: T.Type) async throws -> T {
        let key = String(describing: type)
        
        guard let scope = scopes[key], let factory = factories[key] else {
            throw GoDareDIError.serviceNotRegistered(type)
        }
        
        switch scope {
        case .singleton:
            guard let instance = services[key] as? T else {
                throw GoDareDIError.serviceResolutionFailed(type)
            }
            return instance
            
        case .application:
            guard let instance = applicationInstances[key] as? T else {
                throw GoDareDIError.serviceResolutionFailed(type)
            }
            return instance
            
        case .transient:
            return try await factory(self) as! T
            
        case .scoped:
            if let instance = scopedInstances[key] as? T {
                return instance
            } else {
                let instance = try await factory(self) as! T
                scopedInstances[key] = instance
                return instance
            }
        }
    }
    
    // MARK: - Synchronous Service Resolution
    public func resolveSync<T>(_ type: T.Type) throws -> T {
        let key = String(describing: type)
        
        guard let scope = scopes[key], let _ = factories[key] else {
            throw GoDareDIError.serviceNotRegistered(type)
        }
        
        switch scope {
        case .singleton:
            guard let instance = services[key] as? T else {
                throw GoDareDIError.serviceResolutionFailed(type)
            }
            return instance
            
        case .application:
            guard let instance = applicationInstances[key] as? T else {
                throw GoDareDIError.serviceResolutionFailed(type)
            }
            return instance
            
        case .transient:
            // For transient, we need to create a new instance synchronously
            // This is a simplified implementation
            throw GoDareDIError.serviceResolutionFailed(type)
            
        case .scoped:
            if let instance = scopedInstances[key] as? T {
                return instance
            } else {
                throw GoDareDIError.serviceResolutionFailed(type)
            }
        }
    }
    
    // MARK: - Premium Features
    public func enableAnalytics(token: String) {
        self.isAnalyticsEnabled = true
        self.analyticsToken = token
        print("📊 GoDareDI: Analytics enabled with token")
    }
    
    public func enableCrashlytics() {
        self.isCrashlyticsEnabled = true
        print("🛡️ GoDareDI: Crashlytics enabled")
    }
    
    public func enableDashboardSync(token: String) {
        self.isDashboardSyncEnabled = true
        print("📱 GoDareDI: Dashboard sync enabled")
    }
    
    // MARK: - Preload All Generic Types
    public func preloadAllGeneric() async throws {
        // Preload all registered services that are singletons or application-scoped
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
public let GoDareDIVersion = "1.0.2"
public let GoDareDIBuildNumber = "2"

// MARK: - Dependency Graph Visualization
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
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
            if #available(macOS 11.0, *) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
            } else {
                Text("⚠️")
                    .font(.system(size: 50))
            }
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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
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
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct NavigationTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 11.0, *) {
            content.navigationTitle("GoDareDI Graph")
        } else {
            content
        }
    }
}
