//
//  ContainerBuilder.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - Container Builder
public actor ContainerBuilder: Sendable {
    private var container: AdvancedDIContainerImpl
    private var registrations: [() async throws -> Void] = []
    
    public init(config: DIContainerConfig = DIContainerConfig()) async {
        self.container = await AdvancedDIContainerImpl(config: config)
    }
    
    // MARK: - Registration Methods
    public func register<T: Sendable>(
        _ type: T.Type,
        scope: DependencyScope = .singleton,
        lifetime: DependencyLifetime = .application,
        factory: @escaping @Sendable (AdvancedDIContainer) async throws -> T
    ) async -> ContainerBuilder {
        registrations.append {
            await self.container.register(type, scope: scope, lifetime: lifetime, factory: factory)
        }
        return self
    }
    
    public func registerSync<T: Sendable>(
        _ type: T.Type,
        scope: DependencyScope = .singleton,
        lifetime: DependencyLifetime = .application,
        factory: @escaping @Sendable (AdvancedDIContainer) throws -> T
    ) async -> ContainerBuilder {
        registrations.append {
            await self.container.registerSync(type, scope: scope, lifetime: lifetime, factory: factory)
        }
        return self
    }
    
    // MARK: - Instance Registration
    public func registerInstance<T: Sendable>(
        _ type: T.Type,
        instance: T,
        scope: DependencyScope = .singleton
    ) async -> ContainerBuilder {
        registrations.append {
            await self.container.register(type, scope: scope) { _ in
                return instance
            }
        }
        return self
    }
    
    // MARK: - Module Registration
    public func registerModule(_ module: DIModule) async -> ContainerBuilder {
        registrations.append {
            try await module.configure(container: self.container)
        }
        return self
    }
    
    // MARK: - Build
    public func build() async throws -> AdvancedDIContainer {
        for registration in registrations {
            try await registration()
        }
        return container
    }
}

// MARK: - DI Module Protocol
public protocol DIModule: Sendable {
    func configure(container: AdvancedDIContainer) async throws
}

// MARK: - Convenience Extensions
extension ContainerBuilder {
    
    // MARK: - Common Patterns
    public func registerService<T: Sendable>(
        _ type: T.Type,
        factory: @escaping @Sendable (AdvancedDIContainer) async throws -> T
    ) async -> ContainerBuilder {
        return await register(type, scope: .singleton, factory: factory)
    }
    
    public func registerRepository<T: Sendable>(
        _ type: T.Type,
        factory: @escaping @Sendable (AdvancedDIContainer) async throws -> T
    ) async -> ContainerBuilder {
        return await register(type, scope: .scoped, factory: factory)
    }
    
    public func registerUseCase<T: Sendable>(
        _ type: T.Type,
        factory: @escaping @Sendable (AdvancedDIContainer) async throws -> T
    ) async -> ContainerBuilder {
        return await register(type, scope: .transient, factory: factory)
    }
    
    public func registerViewModel<T: Sendable>(
        _ type: T.Type,
        factory: @escaping @Sendable (AdvancedDIContainer) async throws -> T
    ) async -> ContainerBuilder {
        return await register(type, scope: .lazy, factory: factory)
    }
}
