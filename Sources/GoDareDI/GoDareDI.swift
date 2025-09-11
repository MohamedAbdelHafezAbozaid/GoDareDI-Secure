import Foundation

// MARK: - GoDareDI Framework
// Advanced Dependency Injection Framework
// Secure Binary Distribution - Source Code Protected

// MARK: - Service Scope
public enum ServiceScope {
    case singleton
    case transient
    case scoped
}

// MARK: - Dependency Injection Container Protocol
public protocol AdvancedDIContainer {
    func register<T>(_ type: T.Type, scope: ServiceScope, factory: @escaping (AdvancedDIContainer) async throws -> T) async throws
    func resolve<T>(_ type: T.Type) async throws -> T
    func enableAnalytics(token: String)
    func enableCrashlytics()
    func enableDashboardSync(token: String)
}

// MARK: - Advanced DI Container Implementation
public class AdvancedDIContainerImpl: AdvancedDIContainer {
    
    // MARK: - Private Properties
    private var services: [String: Any] = [:]
    private var factories: [String: (AdvancedDIContainer) async throws -> Any] = [:]
    private var scopes: [String: ServiceScope] = [:]
    private var scopedInstances: [String: Any] = [:]
    private var isAnalyticsEnabled = false
    private var isCrashlyticsEnabled = false
    private var isDashboardSyncEnabled = false
    private var analyticsToken: String?
    
    // MARK: - Initialization
    public init() {
        print("🔒 GoDareDI: Secure Binary Framework Initialized")
    }
    
    // MARK: - Service Registration
    public func register<T>(_ type: T.Type, scope: ServiceScope, factory: @escaping (AdvancedDIContainer) async throws -> T) async throws {
        let key = String(describing: type)
        factories[key] = factory
        scopes[key] = scope
        
        if scope == .singleton {
            let instance = try await factory(self)
            services[key] = instance
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
public let GoDareDIVersion = "1.0.0"
public let GoDareDIBuildNumber = "1"
