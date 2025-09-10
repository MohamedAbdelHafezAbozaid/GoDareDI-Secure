//
//  Registration.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - Registration Extensions
extension AdvancedDIContainerImpl {
    
    // MARK: - Registration Methods
    public func register<T: Sendable>(
        _ type: T.Type,
        scope: DependencyScope,
        factory: @escaping @Sendable (AdvancedDIContainer) async throws -> T
    ) where T: Sendable {
        register(type, scope: scope, lifetime: .application, factory: factory)
    }
    
    public func register<T: Sendable>(
        _ type: T.Type,
        scope: DependencyScope,
        lifetime: DependencyLifetime = .application,
        factory: @escaping @Sendable (AdvancedDIContainer) async throws -> T
    ) {
        let key = String(describing: type)
        let metadata = DependencyMetadata(type: type, scope: scope, lifetime: lifetime)
        
        self.typeRegistry[key] = metadata
        self.factories[key] = .async(factory)
        
        // 🔥 ANALYTICS: Track dependency registration
        Task {
            if let analyticsProvider = analyticsProvider {
                await analyticsProvider.trackDependencyRegistration(key, scope: scope)
            }
        }
        
        print("🔧 Registered \(key) with scope: \(scope) and dependencies: []")
    }

    public func registerSync<T: Sendable>(
        _ type: T.Type,
        scope: DependencyScope,
        lifetime: DependencyLifetime = .application,
        factory: @escaping @Sendable (AdvancedDIContainer) throws -> T
    ) {
        let key = String(describing: type)
        let metadata = DependencyMetadata(type: type, scope: scope, lifetime: lifetime)
        
        self.typeRegistry[key] = metadata
        self.factories[key] = .sync(factory)
        
        // 🔥 ANALYTICS: Track dependency registration
        Task {
            if let analyticsProvider = analyticsProvider {
                await analyticsProvider.trackDependencyRegistration(key, scope: scope)
            }
        }
        
        print("🔧 Registered \(key) with scope: \(scope) and dependencies: []")
    }
    
    public func registerSync<T: Sendable>(
        _ type: T.Type,
        scope: DependencyScope,
        factory: @escaping @Sendable (AdvancedDIContainer) throws -> T
    ) where T: Sendable {
        registerSync(type, scope: scope, lifetime: .application, factory: factory)
    }
    
    // MARK: - Dependency Extraction
    private func extractDependenciesFromType<T: Sendable>(_ type: T.Type) -> [String] {
        _ = String(describing: type)
        return []
    }
    
    // MARK: - Factory Management
    internal func getFactory(for key: String) -> FactoryType? {
        return factories[key]
    }
    
    // MARK: - Metadata Access
    public func getMetadata<T>(_ type: T.Type) -> DependencyMetadata? {
        let key = String(describing: type)
        return typeRegistry[key]
    }
    
    public func registerWithMetadata<T>(_ type: T.Type, metadata: DependencyMetadata) {
        let key = String(describing: type)
        self.typeRegistry[key] = metadata
    }
    
    public func getMetadata(for key: String) -> DependencyMetadata? {
        return typeRegistry[key]
    }
    
    public func isRegistered<T>(_ type: T.Type) -> Bool {
        let key = String(describing: type)
        return typeRegistry[key] != nil
    }
}
