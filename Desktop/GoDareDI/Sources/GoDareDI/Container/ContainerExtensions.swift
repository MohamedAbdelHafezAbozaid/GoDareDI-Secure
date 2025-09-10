//
//  ContainerExtensions.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - Container Extensions
extension AdvancedDIContainer {
    
    // MARK: - Convenience Methods
    public func registerService<T: Sendable>(
        _ type: T.Type,
        factory: @escaping @Sendable (AdvancedDIContainer) async throws -> T
    ) {
        Task {
            register(type, scope: .singleton, factory: factory)
        }
    }
    
    public func registerRepository<T: Sendable>(
        _ type: T.Type,
        factory: @escaping @Sendable (AdvancedDIContainer) async throws -> T
    ) {
        Task {
            register(type, scope: .scoped, factory: factory)
        }
    }
    
    public func registerUseCase<T: Sendable>(
        _ type: T.Type,
        factory: @escaping @Sendable (AdvancedDIContainer) async throws -> T
    ) {
        Task {
            register(type, scope: .transient, factory: factory)
        }
    }
    
    public func registerViewModel<T: Sendable>(
        _ type: T.Type,
        factory: @escaping @Sendable (AdvancedDIContainer) async throws -> T
    ) {
        Task {
            register(type, scope: .lazy, factory: factory)
        }
    }
    
    // MARK: - Instance Registration
    public func registerInstance<T: Sendable>(
        _ type: T.Type,
        instance: T,
        scope: DependencyScope = .singleton
    ) {
        Task {
            register(type, scope: scope) { _ in
                return instance
            }
        }
    }
    
    // MARK: - Batch Operations
    public func registerBatch<T: Sendable>(
        _ types: [T.Type],
        scope: DependencyScope = .singleton,
        factory: @escaping @Sendable (AdvancedDIContainer, T.Type) async throws -> T
    ) {
        Task {
            for type in types {
                register(type, scope: scope) { container in
                    return try await factory(container, type)
                }
            }
        }
    }
    
    // MARK: - Conditional Registration
    public func registerIf<T: Sendable>(
        _ condition: Bool,
        _ type: T.Type,
        scope: DependencyScope = .singleton,
        factory: @escaping @Sendable (AdvancedDIContainer) async throws -> T
    ) {
        guard condition else { return }
        Task {
            register(type, scope: scope, factory: factory)
        }
    }
    
    // MARK: - Environment-based Registration
    public func registerForEnvironment<T: Sendable>(
        _ type: T.Type,
        scope: DependencyScope = .singleton,
        development: @escaping @Sendable (AdvancedDIContainer) async throws -> T,
        production: @escaping @Sendable (AdvancedDIContainer) async throws -> T
    ) {
        Task {
            #if DEBUG
            register(type, scope: scope, factory: development)
            #else
            register(type, scope: scope, factory: production)
            #endif
        }
    }
}

// MARK: - Container Factory
public struct ContainerFactory {
    
    public static func create(
        config: DIContainerConfig = DIContainerConfig(),
        configure: @escaping @Sendable (ContainerBuilder) async -> ContainerBuilder = { $0 }
    ) async throws -> AdvancedDIContainer {
        let builder = await ContainerBuilder(config: config)
        let configuredBuilder = await configure(builder)
        return try await configuredBuilder.build()
    }
    
    public static func createWithModules(
        config: DIContainerConfig = DIContainerConfig(),
        modules: [DIModule]
    ) async throws -> AdvancedDIContainer {
        let builder = await ContainerBuilder(config: config)
        
        for module in modules {
            _ = await builder.registerModule(module)
        }
        
        return try await builder.build()
    }
}
